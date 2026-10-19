// Explicit opt-in: exercises the real backend with temporary synthetic users.
const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const {initializeApp, deleteApp} = require('firebase/app');
const {getAuth, createUserWithEmailAndPassword, signInWithEmailAndPassword, signOut, deleteUser} = require('firebase/auth');
const {getFirestore, doc, setDoc, updateDoc, deleteDoc, getDoc, getDocs, collection, collectionGroup, query, where, serverTimestamp, Timestamp, terminate} = require('firebase/firestore');
if (process.env.RUN_CLOUD_TEST !== 'piramidgame-ifpr-mstaniscia') throw Error('Set RUN_CLOUD_TEST=piramidgame-ifpr-mstaniscia to explicitly run against the real project.');
const config = {projectId:'piramidgame-ifpr-mstaniscia',apiKey:'AIzaSyAgKb3pEUENi-lQTvf00meLerXqXePJ6hU',appId:'1:280712703203:web:ce64818e39009c595569d6'};
const run = crypto.randomUUID();
const apps = [initializeApp(config, 'cloud-a'),initializeApp(config, 'cloud-b')];
const auths = apps.map(app => getAuth(app)), dbs = apps.map(app => getFirestore(app));
const password = crypto.randomBytes(24).toString('base64url');
const emails = [0,1].map(i => `smoke-${run}-${i}@example.com`);
const personId = `smoke-${run}`;
const keys = ['resenha','presenca_vip','aura','modo_parceiro','carisma_natural','humor_de_milhoes','energia_de_grupo','criatividade_caotica','modo_atleta','talento_de_palco','drip_escolar','coracao_de_dorama','queridinho_dos_professores','cerebro_turbo','caos_controlado'];
const passed=[];
async function denied(action) { await assert.rejects(action, e => e.code === 'permission-denied'); }
(async () => {
  try {
    await denied(() => getDocs(collection(dbs[0], 'people'))); passed.push('anonymous denied');
    for (let i=0;i<2;i++) await createUserWithEmailAndPassword(auths[i],emails[i],password);
    passed.push('two real email/password registrations');
    await signOut(auths[0]);
    await assert.rejects(() => signInWithEmailAndPassword(auths[0],emails[0],password+'bad'));
    await signInWithEmailAndPassword(auths[0],emails[0],password); passed.push('login and invalid password');
    const uid=auths[0].currentUser.uid;
    await setDoc(doc(dbs[0],'people',personId), {name:'Teste automatizado Firebase',nickname:'smoke',course:'TADS',year:2026,birthDate:Timestamp.fromDate(new Date('2000-01-01')),createdBy:uid,linkedUid:null,active:true});
    assert.equal((await getDoc(doc(dbs[1],'people',personId))).data().createdBy,uid); passed.push('shared person across sessions');
    await denied(() => updateDoc(doc(dbs[1],'people',personId),{name:'Unauthorized'})); passed.push('owner edit protection');
    for(let i=0;i<2;i++) await setDoc(doc(dbs[i],'people',personId,'ratings',auths[i].currentUser.uid),{personId,evaluatorUid:auths[i].currentUser.uid,scores:Object.fromEntries(keys.map(k=>[k,i===0?3:5])),total:i===0?45:75,date:serverTimestamp()});
    const ratings=(await getDocs(collectionGroup(dbs[0],'ratings'))).docs.map(d=>d.data()).filter(d=>d.personId===personId);
    assert.equal(ratings.length,2); assert.equal(ratings.reduce((sum,d)=>sum+d.total,0)/2,60); passed.push('global mean 60 / own total 45');
    await denied(() => updateDoc(doc(dbs[1],'people',personId,'ratings',auths[0].currentUser.uid),{total:15})); passed.push('rating ownership');
    await denied(() => updateDoc(doc(dbs[0],'people',personId,'ratings',uid),{total:15})); passed.push('forged total denied');
    await signOut(auths[0]); await denied(()=>getDocs(collection(dbs[0],'people'))); passed.push('logout revokes server access');
    await signInWithEmailAndPassword(auths[0],emails[0],password);
  } finally {
    for(let i=0;i<2;i++) if(auths[i].currentUser) await deleteDoc(doc(dbs[i],'people',personId,'ratings',auths[i].currentUser.uid)).catch(()=>{});
    if(auths[0].currentUser) {
      const ref=doc(dbs[0],'people',personId);
      if((await getDoc(ref)).exists()) await updateDoc(ref,{active:false});
      assert.equal((await getDocs(query(collection(dbs[0],'people'),where('active','==',true)))).docs.some(d=>d.id===personId),false);
    }
    for(const a of auths) if(a.currentUser) await deleteUser(a.currentUser);
    await Promise.all(dbs.map(terminate)); await Promise.all(apps.map(deleteApp));
  }
  console.log(JSON.stringify({project:config.projectId,passed,cleanup:'temporary Auth users and ratings deleted; synthetic person archived',archivedPersonId:personId},null,2));
})().catch(e=>{console.error(e.code||e.message);process.exitCode=1;});
