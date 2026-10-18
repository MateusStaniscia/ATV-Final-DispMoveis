const { test } = require('node:test');
const assert = require('node:assert/strict');
const { initializeApp, deleteApp } = require('firebase/app');
const { getAuth, connectAuthEmulator, createUserWithEmailAndPassword,
  signInWithEmailAndPassword, signOut, sendPasswordResetEmail } = require('firebase/auth');
const { getFirestore, connectFirestoreEmulator, doc, setDoc, getDoc, terminate, Timestamp, serverTimestamp } = require('firebase/firestore');
const scores=Object.fromEntries(["resenha","presenca_vip","aura","modo_parceiro","carisma_natural","humor_de_milhoes","energia_de_grupo","criatividade_caotica","modo_atleta","talento_de_palco","drip_escolar","coracao_de_dorama","queridinho_dos_professores","cerebro_turbo","caos_controlado"].map(k=>[k,3]));
test('Authentication real do emulador: cadastro, senha errada, login, reset e logout', async () => {
  const app=initializeApp({apiKey:'demo-api-key',projectId:'demo-piramid-game'},'auth-'+Date.now());
  const auth=getAuth(app);
  connectAuthEmulator(auth,'http://127.0.0.1:9099',{disableWarnings:true});
  const db=getFirestore(app);
  connectFirestoreEmulator(db,'127.0.0.1',8080);
  const email='teste-'+Date.now()+'@example.com', password='SenhaTeste123!';
  try {
    const credential=await createUserWithEmailAndPassword(auth,email,password);
    const uid=credential.user.uid;
    const ref=doc(db,'people','integracao');
    await setDoc(doc(db,'users',uid), {name:'',email,photo:'',provider:'password',personId:null});
    await setDoc(ref,{name:'Integracao',course:'TADS',year:2026,nickname:'',
      birthDate:Timestamp.fromDate(new Date('2000-01-01')),createdBy:uid,linkedUid:null,active:true});
    assert.equal((await getDoc(ref)).data().name,'Integracao');
    await setDoc(doc(db,'people','integracao','ratings',uid),
      {evaluatorUid:uid,personId:'integracao',scores,total:45,date:serverTimestamp()});
    assert.equal((await getDoc(doc(db,'users',uid))).data().email,email);
    await sendPasswordResetEmail(auth,email);
    await signOut(auth);
    assert.equal(auth.currentUser,null);
    await assert.rejects(getDoc(ref));
    await assert.rejects(signInWithEmailAndPassword(auth,email,'senha-errada'));
    const login=await signInWithEmailAndPassword(auth,email,password);
    assert.equal(login.user.uid,uid);
    assert.equal((await getDoc(ref)).exists(),true);
    await assert.rejects(createUserWithEmailAndPassword(auth,email,password));
    await signOut(auth);
  } finally {
    await terminate(db);
    await deleteApp(app);
  }
});
