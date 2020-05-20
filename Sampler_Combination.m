function [users,items1,items2]=Sampler_Combination(numSamples,nitems,nusers,row,col,xadj,adj,deg,...
    byuser,uniformsampling, MR, SIM)

% algorithm based on the combination of popularity and similarity

MR_F = full(MR);
SIM_F = full(SIM);

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

% generate the popularity vector for all items
max_p = max(count);
min_p = min(count);
pop = (count-min_p)/(max_p-min_p);

if (uniformsampling)
    
    % set value of mu, which indicates the weight of similarity;
    % use the formula described in the final report to generate scores
    % based on popularity and similarity 
    % for all negative items in the (u,i,j) tuples;
    % can change the value of mu according to users' requirements
    mu = 0.3;  
    Select_combination = mu*SIM_F(items1,:)+(1-mu)*pop';
    
    % pre-select to make sure all the negative items are not rated
    Select_row = MR_F(users,:);
    Select_row(find(Select_row))=2;
    Select_row(find(~Select_row))=1;
    Select_row(find(Select_row==2))=0;

    % use the positive items "items1" to find corresponding scores
    % update the select_row matrix
    Select_row = Select_combination.*Select_row;
    
    % sort the negative items based on the scores generated above
    [~, indx] = sort(Select_row,2,'descend');

    % choose the negative items from the negative item pools;
    % basicly, generate the negative item pool with 800 items;
    % can change 800 to other values to modify the size of the item pool
    randomSelect = ceil(800*rand(numSamples,1));
    items2 = indx(sub2ind(size(indx),(1:numSamples)',randomSelect));

    % re-select if already rated
    checkIndx = find(MR_F(nusers*(items2-1)+users)~=0);
    while (~isempty(checkIndx))
        length(checkIndx)
        randomSelect = ceil(800*rand(length(checkIndx),1));
        select_indx=indx(checkIndx,:);
        new_index = select_indx(sub2ind(size(select_indx),(1:length(checkIndx))',randomSelect));
        items2(checkIndx) = new_index;

        % check again until all items chosen are not rated
        checkIndx = find(MR_F(nusers*(items2-1)+users)~=0);
    end
    
end

end