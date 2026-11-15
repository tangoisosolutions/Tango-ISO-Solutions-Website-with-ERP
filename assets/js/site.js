const SB_URL='https://hihresztklcxlvcxzvjp.supabase.co',SB_KEY='sb_publishable_KNEF2kOc4kPFiuhiT17T0g_wt9UpBxc',W3='5ec7c8c4-0921-4335-a950-3717f4875b64',MAIL='tangoisosolutions@gmail.com';
function toggleMenu(){document.getElementById('singleLinks').classList.toggle('open')}
(function(){const y=document.getElementById('year');if(y)y.textContent=new Date().getFullYear();
const cur=location.pathname.split('/').pop()||'index.html';
document.querySelectorAll('#singleLinks > a,#singleLinks .dd-t').forEach(a=>{if(a.getAttribute('href')===cur)a.classList.add('active')});
const sp=new URLSearchParams(location.search).get('service'),sel=document.getElementById('f-service');if(sp&&sel)sel.value=sp})();
const msg=(t,c)=>{const m=document.getElementById('fmsg');m.textContent=t;m.className=c||''};
async function w3(subject,fields){try{const r=await fetch('https://api.web3forms.com/submit',{method:'POST',headers:{'Content-Type':'application/json',Accept:'application/json'},body:JSON.stringify({access_key:W3,subject:'Tango Website: '+subject,from_name:'Tango ISO Solutions Website',...fields})});return (await r.json()).success===true}catch(e){return false}}
const iq=document.getElementById('inqForm');
if(iq)iq.addEventListener('submit',async e=>{e.preventDefault();const f=e.target,d=Object.fromEntries(new FormData(f));
if(d.website)return msg('Thank you!','ok');if(!f.checkValidity()){f.reportValidity();return}
const b=f.querySelector('button');b.disabled=true;msg('Sending…');
let ok=false;try{const r=await fetch(SB_URL+'/rest/v1/inquiries',{method:'POST',headers:{apikey:SB_KEY,'Content-Type':'application/json',Prefer:'return=minimal'},body:JSON.stringify({name:d.name,company:d.company||null,email:d.email,phone:d.phone||null,service:d.service,message:d.message})});ok=r.ok}catch(_){}
const mail=await w3('Inquiry - '+d.service,{name:d.name,email:d.email,phone:d.phone,company:d.company,service:d.service,message:d.message});
if(ok||mail){msg('Thank you! Your inquiry has been received. We will get back to you soon.','ok');f.reset()}else msg('Sorry, something went wrong. Please email '+MAIL,'err');b.disabled=false});
const cf=document.getElementById('careerForm');
if(cf)cf.addEventListener('submit',async e=>{e.preventDefault();const f=e.target,d=Object.fromEntries(new FormData(f));
if(d.website)return msg('Thank you!','ok');if(!f.checkValidity()){f.reportValidity();return}
const file=f.resume.files[0],ext=(file.name.split('.').pop()||'').toLowerCase();
if(!['pdf','doc','docx'].includes(ext))return msg('Resume must be a PDF, DOC or DOCX file.','err');
if(file.size>5*1024*1024)return msg('Resume must be 5 MB or smaller.','err');
const b=f.querySelector('button');b.disabled=true;msg('Submitting…');
const ref='CR-'+Date.now().toString(36).toUpperCase(),path='careers/'+ref+'/'+file.name.replace(/[^\w.\-]+/g,'_');
let up=false;try{const r=await fetch(SB_URL+'/storage/v1/object/client-uploads/'+path,{method:'POST',headers:{apikey:SB_KEY,'Content-Type':file.type||'application/octet-stream','x-upsert':'false'},body:file});up=r.ok}catch(_){}
const mail=await w3('Career application - '+d.name,{name:d.name,email:d.email,phone:d.phone,experience:d.experience,reference:ref,resume:up?'Stored in Supabase Storage: client-uploads/'+path:'Upload failed - ask applicant to email resume'});
if(mail){msg('Thank you! Your application has been submitted (reference '+ref+').','ok');f.reset()}else msg('Sorry, something went wrong. Please email your resume to '+MAIL,'err');b.disabled=false});
document.querySelectorAll('.acc-t').forEach(b=>{const p=document.getElementById(b.getAttribute('aria-controls')),set=o=>{b.setAttribute('aria-expanded',o);p.hidden=!o};b.addEventListener('click',()=>set(b.getAttribute('aria-expanded')!=='true'));if(location.hash==='#iso-consultancy')set(true)});
