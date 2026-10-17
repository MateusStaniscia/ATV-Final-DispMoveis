const { before, after, beforeEach, test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { doc, collection, setDoc, getDoc, getDocs, updateDoc, deleteDoc } = require('firebase/firestore');
let env;
const student = (id='aluno-1') => ({
  id, name: 'Aluno de Teste', nickname: 'Teste', course: 'INFO', year: 2026,
  birthDate: '2005-01-01T00:00:00.000',
  scores: Object.fromEntries(["resenha","presenca_vip","aura","modo_parceiro","carisma_natural","humor_de_milhoes","energia_de_grupo","criatividade_caotica","modo_atleta","talento_de_palco","drip_escolar","coracao_de_dorama","queridinho_dos_professores","cerebro_turbo","caos_controlado"].map(k=>[k,3])),
});
const path = 'users/alice/students/aluno-1';
before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-piramid-game',
    firestore: { host: '127.0.0.1', port: 8080, rules: readFileSync('firestore.rules', 'utf8') },
  });
});
beforeEach(() => env.clearFirestore());
after(() => env?.cleanup());

test('proprietário cria, lista, lê, atualiza e exclui aluno', async () => {
  const db=env.authenticatedContext('alice').firestore();
  const ref=doc(db,path);
  await assertSucceeds(setDoc(ref,student()));
  assert.equal((await getDocs(collection(db,'users/alice/students'))).size,1);
  assert.equal((await getDoc(ref)).data().scores.aura,3);
  await assertSucceeds(updateDoc(ref,{name:'Atualizado', 'scores.aura':5}));
  assert.equal((await getDoc(ref)).data().name,'Atualizado');
  await assertSucceeds(deleteDoc(ref));
  assert.equal((await getDoc(ref)).exists(),false);
});
test('usuário anônimo não pode executar nenhuma operação', async () => {
  const db=env.unauthenticatedContext().firestore();
  const ref=doc(db,path);
  await assertFails(getDoc(ref));
  await assertFails(getDocs(collection(db,'users/alice/students')));
  await assertFails(setDoc(ref,student()));
  await assertFails(updateDoc(ref,{name:'Invadido'}));
  await assertFails(deleteDoc(ref));
});
test('segunda conta não pode ler, listar, criar, editar ou excluir dados alheios', async () => {
  await setDoc(doc(env.authenticatedContext('alice').firestore(),path),student());
  const db=env.authenticatedContext('bob').firestore();
  const ref=doc(db,path);
  await assertFails(getDoc(ref));
  await assertFails(getDocs(collection(db,'users/alice/students')));
  await assertFails(setDoc(doc(db,'users/alice/students/outro'),student('outro')));
  await assertFails(updateDoc(ref,{name:'Invadido'}));
  await assertFails(deleteDoc(ref));
  assert.equal((await getDocs(collection(db,'users/bob/students'))).size,0);
});
for (const [label,patch] of [
  ['nome vazio',{name:''}],
  ['nome só com espaços',{name:'   '}],
  ['nome longo',{name:'a'.repeat(121)}],
  ['curso inválido',{course:'OUTRO'}],
  ['ano inválido',{year:2027}],
  ['ano fracionário',{year:2025.5}],
  ['apelido longo',{nickname:'a'.repeat(61)}],
  ['ID divergente',{id:'outro'}],
  ['nascimento inválido',{birthDate:123}],
  ['campo extra',{admin:true}],
  ['notas incompletas',{scores:{aura:3}}],
  ['nota acima do limite',{scores:{...student().scores,aura:6}}],
  ['nota abaixo do limite',{scores:{...student().scores,aura:0}}],
  ['nota fracionária',{scores:{...student().scores,aura:3.5}}],
  ['critério extra',{scores:{...student().scores,outro:3}}],
]) {
  test('rejeita '+label, async () => {
    const db=env.authenticatedContext('alice').firestore();
    await assertFails(setDoc(doc(db,path),{...student(),...patch}));
  });
}
test('nega campos obrigatórios ausentes e caminhos fora do modelo', async () => {
  const db=env.authenticatedContext('alice').firestore();
  const data=student();delete data.name;
  await assertFails(setDoc(doc(db,path),data));
  await assertFails(setDoc(doc(db,'students/aluno-1'),student()));
  await assertFails(setDoc(doc(db,'users/alice'),{admin:true}));
});
