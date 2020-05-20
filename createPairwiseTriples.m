% Create pairwise matrix from ratings
function P = createPairwiseTriples(R, dominating_order,doincludeequality)

if (nargin<2)
    dominating_order = false;
end
if (nargin<3)
    doincludeequality = false;
end

% guess the size of the output matrix. Should do something better here
% As soon as the size is greater than s, then the program will start to
% crawl. 

P=zeros(size(R,1),4);
pSize = length(P);
[~,indx] = sort(R(:,1));
Rs = R(indx,:);
i = 1;
c = 0;
user_i=Rs(1,1);

while (i<=size(Rs,1))
    if (mod(user_i,100)==0)
%         fprintf('%d\n', user_i);
    end
    user_i = Rs(i,1);
    j=i;
    items=[];
    ratings=[];
    
    %loop through items for user
    while (j<=size(Rs,1) && Rs(j,1)==user_i)
        items=[items;Rs(j,2)];
        ratings=[ratings;Rs(j,3)];
        j=j+1;
    end
    i=j;

    % sort ratings and items
    urats=unique(ratings);
    [srats,indx]=sort(ratings);
    items=items(indx);
    
    xtab=zeros(length(urats)+1,1);    
    xtab(1) = 1; 
    u = urats(1); 
    
    %sets tab for rating of sorted item
    l = 1;
    for k=1:length(srats),
        if (srats(k) ~= u)
            u = srats(k);
            l = l+1;
            xtab(l) = k;
        end
    end
    xtab(end)=length(items)+1;
    
    uc=0;
    for k=1:length(urats),
        if (doincludeequality)
           uc = uc + (xtab(k+1)-xtab(k))*(xtab(k+1)-xtab(k)-1);
        end
        for j=xtab(k):(xtab(k+1)-1),
            for l=xtab(k+1):length(items),
                uc=uc+1;
            end
        end
    end
    if (c+uc > pSize)
        nP = zeros(2*pSize,4);
        nP(1:pSize,:) = P(1:pSize,:);
        P = nP;
        pSize = 2*pSize;
    end
    
    %loops through tabs of ratings, sets higher rated item for all at that rating
    for k=1:length(urats),
        
        % originally, doincludeequality = false
        if (doincludeequality)
            for j=xtab(k):(xtab(k+1)-1),
                for l=(j+1):(xtab(k+1)-1),
                    c=c+1;
                    P(c,:) = [user_i, items(j), items(l),1];
                    c=c+1;
                    P(c,:) = [user_i, items(l), items(j),1];
                end
            end
        end
        
        for j=xtab(k):(xtab(k+1)-1),
            for l=xtab(k+1):length(items),
                    c=c+1;
                                          
                        if (dominating_order)
                            P(c,:) = [user_i, items(l), items(j),srats(l)-srats(j)];                        
                        else
                            if (items(l)<items(j))
                                minindx = l; maxindx=j;
                            else
                                minindx = j; maxindx=l;
                            end
                            P(c,:) = [user_i, items(maxindx), items(minindx),srats(maxindx)-srats(minindx)];                        
                        end
                        
            end
        end
        
    end
end
P = P(1:c,:);



