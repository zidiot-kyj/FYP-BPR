function [users,items1,items2,indx]=Sampler_MIP(numSamples,R,row,col,xadj,adj,deg,...
    byuser,uniformsampling)

% algorithm based on popularity (sample the most popular items);
% Imbalanced-Popular-sampling

nusers = size(R,1);
nitems = sqrt(size(R,2));
if (~byuser)
    %  pick a (user,itempair) uniformly at random
    pos = ceil(rand(numSamples,1)*length(row));
    users = row(pos);
    itempairs = col(pos);
else
    % pick a user uniformly at random
    users = ceil(rand(numSamples,1)*nusers);
    % pick one of the users item-pairs uniformly at random.
    itempairs = adj(xadj(users)+ceil(rand(numSamples,1).*deg(users))-1); 
end
% pull the items out of the item-pairs
items1 = mod(itempairs-1,nitems)+1;
items2 = floor((itempairs-1)/nitems)+1;

% represent all items
allitems = items1;

% define an array to count how many times each item occurs
count = zeros(nitems,1);
for i = 1:length(allitems)
   count(allitems(i))= count(allitems(i))+1;
end
total = sum(count);

% define a vector to represent the proporation for each item
pro = zeros(nitems,1);
for i =1:nitems
    pro(i) = 100*count(i)/total;
end

% define a vector to represent values using sigmoid function
sig = zeros(nitems,1);
for i =1:nitems
    sig(i) =  1/(1+exp(-pro(i)));
end

total2 = sum(sig);
scale = zeros(nitems,1);
for i =1:nitems
    scale(i) = sig(i)/total2;
end
pop_scale = round(scale*total);
cum = cumsum(pop_scale);

% define an array based on popularity of all items
pop= ones(total,1);
indx = 1;
for n =1:nitems
    pop(indx:cum(n))=n;
    indx = cum(n) + 1;
end

if (uniformsampling)
    
    % choose a negative item based on popularity
    j = pop(ceil(rand(numSamples,1)*total)); 
    jpair = items1+nitems*(j-1);
    
    % re-select if already rated
    indx = find(R((jpair-1)*nusers+users)~=0);
    
    while (~isempty(indx))     
        jFix = pop(ceil(rand(length(indx),1)*total));
        
        % change the items
        j(indx) = jFix;
        jpair(indx) = items1(indx) + nitems*(j(indx)-1);
        
        % check again until all items chosen are not rated
        indx = indx(R((jpair(indx)-1)*nusers+users(indx))~=0);
    end
    
    % output negative items
    items2 = j; 
    
end

end