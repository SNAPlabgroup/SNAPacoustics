function lc=cavlen(rate, pc, Tcav)
%calculate cavity length 
[nr,nc]=size(pc);
lc=zeros(1,nc);
lmn=1;		% minimum cavity length (cm)
lmx=12;		% maximum cavity length (cm)

for k=1:nc
   lc(k) = cavity_length(pc(:,k),Tcav, rate,1,12); %in cm
end
return