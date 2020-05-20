function [pop,d,m,s,nusers] = aggregatePerf(popularity,SIM,recommendations,testset,perfunc,varargin)

verbose=true;
users = unique(recommendations(:,1));
nusers = length(users);
uindx(users)=1:nusers;
numRecs = zeros(nusers,1);

for i=1:length(recommendations),
    numRecs(uindx(recommendations(i,1))) = ...
        numRecs(uindx(recommendations(i,1)))+1;
end

% pop: popular bias
% d: diversity
% m: precision
pop = 0; d = 0; m = 0; 

s = 0;
n=1;
validusers = 0;
for i=1:nusers,
    if (verbose && mod(i,1)==0 && validusers>0 )
        fprintf('%d\t%e\t%e\n',i,m/validusers, s/validusers - (m/validusers)^2);
    end
    u = recommendations(n,1);
   
    rec = recommendations(n:(n+numRecs(i)-1),2:3);
    test = testset(testset(:,1)==u, 2:3);
    
    % calculate precision
    [p,err] = perfunc(rec,test,u,varargin);
    
    N=length(rec);
    recitems = rec(1:N,1);
    % calculate diversity
    sum_d = 0;
    for j = 1:N
        for k = (j+1):N
            sum_d = sum_d + (1-SIM(recitems(j),recitems(k)));
        end
    end
    avg_d = 2*sum_d/(N*(N-1));
    
    % calculate popular bias
    sum_p = 0;
    for j = 1:N
        sum_p = sum_p + popularity(recitems(j));
    end
    avg_p = sum_p/N;
    
    % update all performance metrics
    if (err==0)
        pop = pop + avg_p;
        d = d + avg_d;
        m = m+p;
        s = s+p*p;
        validusers=validusers+1;
    end
    n = n+numRecs(i);
end

pop = pop/validusers;
d = d/validusers;
m = m/validusers;
s = s/validusers - m*m;
    
    
