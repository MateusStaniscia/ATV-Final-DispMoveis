const {before,after,beforeEach,test}=require('node:test');
const assert=require('node:assert/strict');
const {readFileSync}=require('node:fs');
const {initializeTestEnvironment,assertSucceeds,assertFails}=require('@firebase/rules-unit-testing');
const {doc,collection,collectionGroup,setDoc,getDoc,getDocs,updateDoc,deleteDoc,writeBatch,Timestamp,serverTimestamp}=require('firebase/firestore');
let env;
const keys=['resenha','presenca_vip','aura','modo_parceiro','carisma_natural','humor_de_milhoes','energia_de_grupo','criatividade_caotica','modo_atleta','talento_de_palco','drip_escolar','coracao_de_dorama','queridinho_dos_professores','cerebro_turbo','caos_controlado'];
const scores=(n=3)=>Object.fromEntries(keys.map(k=>[k,n]));
const person=(uid='alice')=>({name:'Pessoa Teste',nickname:'',course:'TADS',year:2026,birthDate:Timestamp.fromDate(new Date('2000-01-01')),createdBy:uid,linkedUid:null,active:true});
const profile=()=>({name:'',email:'teste@example.com',photo:'',provider:'password',personId:null});
const rating=(uid='alice',pid='p',n=3)=>({evaluatorUid:uid,personId:pid,scores:scores(n),total:n*15,date:serverTimestamp()});
const db=(uid='alice')=>env.authenticatedContext(uid).firestore();
const seed=async()=>{const d=db();await setDoc(doc(d,'people/p'),person());await setDoc(doc(d,'users/alice'),profile());await setDoc(doc(db('bob'),'users/bob'),profile());return d;};
before(async()=>{env=await initializeTestEnvironment({projectId:'demo-piramid-game',firestore:{host:'127.0.0.1',port:8080,rules:readFileSync('firestore.rules','utf8')}});});
beforeEach(()=>env.clearFirestore());after(()=>env?.cleanup());
test('cadastro compartilhado, edição do criador e remoção sem órfãos no ranking',async()=>{
 const d=await seed();const ref=doc(d,'people/p');
 assert.equal((await getDocs(collection(db('bob'),'people'))).size,1);
 await assertSucceeds(updateDoc(ref,{name:'Atualizado'}));
 await setDoc(doc(d,'people/p/ratings/alice'),rating());
 await assertSucceeds(updateDoc(ref,{active:false}));
 await assertFails(updateDoc(ref,{active:true}));
 await assertFails(setDoc(doc(d,'people/p/ratings/alice'),rating()));
 await assertFails(deleteDoc(ref));
});
test('perfil de usuário privado e identidade não pode ser apagada',async()=>{
 const d=await seed();await assertSucceeds(getDoc(doc(d,'users/alice')));
 await assertFails(getDoc(doc(db('bob'),'users/alice')));
 await assertFails(updateDoc(doc(db('bob'),'users/alice'),{name:'Invadido'}));
 await assertFails(deleteDoc(doc(d,'users/alice')));
});
test('anônimo não lê pessoas, perfis nem ranking e não avalia',async()=>{
 await seed();const d=env.unauthenticatedContext().firestore();
 for(const path of ['people/p','users/alice','people/p/ratings/alice'])await assertFails(getDoc(doc(d,path)));
 await assertFails(getDocs(collectionGroup(d,'ratings')));
 await assertFails(setDoc(doc(d,'people/p/ratings/alice'),rating()));
});
test('outro usuário avalia mas não edita ou remove perfil alheio',async()=>{
 await seed();const d=db('bob');await assertSucceeds(setDoc(doc(d,'people/p/ratings/bob'),rating('bob')));
 await assertFails(updateDoc(doc(d,'people/p'),{name:'Invadido'}));
 await assertFails(updateDoc(doc(d,'people/p'),{active:false}));
});
test('cada UID é documento único; edição substitui e não duplica avaliação',async()=>{
 const d=await seed();const ref=doc(d,'people/p/ratings/alice');await setDoc(ref,rating());
 await setDoc(ref,rating('alice','p',5));
 const snap=await getDocs(collection(d,'people/p/ratings'));assert.equal(snap.size,1);assert.equal(snap.docs[0].data().total,75);
 await assertFails(setDoc(doc(d,'people/p/ratings/duplicada'),rating()));
});
test('não é possível falsificar avaliador ou pessoa alvo',async()=>{
 const d=await seed();await assertFails(setDoc(doc(d,'people/p/ratings/alice'),rating('bob')));
 await assertFails(setDoc(doc(d,'people/p/ratings/alice'),rating('alice','outra')));
 await assertFails(setDoc(doc(d,'people/p/ratings/bob'),rating('bob')));
});
test('outra conta não altera nem exclui avaliação existente',async()=>{
 const d=await seed();await setDoc(doc(d,'people/p/ratings/alice'),rating());
 const foreign=doc(db('bob'),'people/p/ratings/alice');await assertFails(updateDoc(foreign,{total:75}));await assertFails(deleteDoc(foreign));
});
test('ranking global lê avaliações de contas distintas',async()=>{
 const d=await seed();await setDoc(doc(d,'people/p/ratings/alice'),rating());
 await setDoc(doc(db('bob'),'people/p/ratings/bob'),rating('bob','p',5));
 const snap=await getDocs(collectionGroup(d,'ratings'));assert.equal(snap.size,2);
 assert.equal(snap.docs.reduce((sum,x)=>sum+x.data().total,0)/snap.size,60);
});
test('vínculo atômico bloqueia autoavaliação e remove avaliação anterior',async()=>{
 const d=await seed();await setDoc(doc(d,'people/p/ratings/alice'),rating());
 const batch=writeBatch(d);batch.update(doc(d,'users/alice'),{personId:'p'});batch.update(doc(d,'people/p'),{linkedUid:'alice'});batch.delete(doc(d,'people/p/ratings/alice'));
 await assertSucceeds(batch.commit());
 assert.equal((await getDoc(doc(d,'people/p/ratings/alice'))).exists(),false);
 await assertFails(setDoc(doc(d,'people/p/ratings/alice'),rating()));
 await assertFails(updateDoc(doc(d,'users/alice'),{personId:null}));
 await assertFails(updateDoc(doc(d,'people/p'),{linkedUid:null}));
 await assertFails(updateDoc(doc(d,'people/p'),{active:false}));
 await assertSucceeds(setDoc(doc(db('bob'),'people/p/ratings/bob'),rating('bob')));
});
test('vínculo incompleto ou para outra conta é negado',async()=>{
 const d=await seed();await assertFails(updateDoc(doc(d,'people/p'),{linkedUid:'alice'}));
 await assertFails(updateDoc(doc(d,'users/alice'),{personId:'p'}));
 await assertFails(updateDoc(doc(d,'people/p'),{linkedUid:'bob'}));
});
test('não permite vínculo que preserve uma autoavaliação',async()=>{
 const d=await seed();await setDoc(doc(d,'people/p/ratings/alice'),rating());
 const batch=writeBatch(d);batch.update(doc(d,'users/alice'),{personId:'p'});batch.update(doc(d,'people/p'),{linkedUid:'alice'});
 await assertFails(batch.commit());
});
test('não permite vincular uma segunda pessoa à mesma conta',async()=>{
 const d=await seed();await setDoc(doc(d,'people/q'),person());
 let b=writeBatch(d);b.update(doc(d,'users/alice'),{personId:'p'});b.update(doc(d,'people/p'),{linkedUid:'alice'});await b.commit();
 b=writeBatch(d);b.update(doc(d,'users/alice'),{personId:'q'});b.update(doc(d,'people/q'),{linkedUid:'alice'});await assertFails(b.commit());
});
test('pessoa pode vincular e editar perfil criado por outra conta',async()=>{
 await seed();const d=db('bob');const b=writeBatch(d);b.update(doc(d,'users/bob'),{personId:'p'});b.update(doc(d,'people/p'),{linkedUid:'bob'});await assertSucceeds(b.commit());
 await assertSucceeds(updateDoc(doc(d,'people/p'),{nickname:'Meu apelido'}));
 await assertFails(setDoc(doc(d,'people/p/ratings/bob'),rating('bob')));
});
for(const [label,patch] of [
 ['nota zero',{scores:{...scores(),aura:0}}],['nota seis',{scores:{...scores(),aura:6}}],['nota fracionária',{scores:{...scores(),aura:2.5}}],
 ['nota textual',{scores:{...scores(),aura:'3'}}],['critério faltante',{scores:{aura:3}}],['critério extra',{scores:{...scores(),extra:3}}],
 ['total adulterado',{total:75}],['campo extra',{admin:true}],['data falsificada',{date:Timestamp.fromDate(new Date('2000-01-01'))}],
])test('rejeita avaliação: '+label,async()=>{const d=await seed();await assertFails(setDoc(doc(d,'people/p/ratings/alice'),{...rating(),...patch}));});
for(const [label,patch] of [
 ['nome vazio',{name:''}],['nome com espaços',{name:'   '}],['nome longo',{name:'x'.repeat(121)}],['curso inválido',{course:'OUTRO'}],
 ['ano inválido',{year:2027}],['ano fracionário',{year:2025.5}],['data futura',{birthDate:Timestamp.fromDate(new Date('2200-01-01'))}],
 ['data textual',{birthDate:'2000-01-01'}],['autor falso',{createdBy:'bob'}],['vínculo na criação',{linkedUid:'alice'}],['campo extra',{scores:scores()}],
])test('rejeita pessoa: '+label,async()=>{await assertFails(setDoc(doc(db(),'people/p'),{...person(),...patch}));});
test('avaliação de pessoa inexistente é negada',async()=>{await assertFails(setDoc(doc(db(),'people/ausente/ratings/alice'),rating('alice','ausente')));});
