function [users,items1,items2]=Sampler_MS(numSamples,nitems,nusers,row,col,xadj,adj,deg,...
    byuser,uniformsampling, MR, SIM)

% algorithm based on similarity (sample the most similar items)

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


if (uniformsampling)
    
    % pre-select to make sure all the negative items are not rated
    Select_row = MR_F(users,:);
    Select_row(find(Select_row))=2;
    Select_row(find(~Select_row))=1;
    Select_row(find(Select_row==2))=0;
    
    % use the positive items "items1" to find corresponding similarity
    % update the select_row matrix
    Select_row = SIM_F(items1,:).*Select_row;
    
    % sort the negative items based on the values of similarity
    [~, indx] = sort(Select_row,2,'descend');
    
    % choose the negative items from the negative item pools;
    % basicly, generate the negative item pool with 500 most similar items;
    % can change 500 to other values to modify the size of the item pool
    randomSelect = ceil(500*rand(numSamples,1));
    items2 = indx(sub2ind(size(indx),(1:numSamples)',randomSelect));

    % re-select if already rated
    checkIndx = find(MR_F(nusers*(items2-1)+users)~=0);
    while (~isempty(checkIndx))
        length(checkIndx);
        randomSelect = ceil(500*rand(length(checkIndx),1));
        select_indx=indx(checkIndx,:);
        new_index = select_indx(sub2ind(size(select_indx),(1:length(checkIndx))',randomSelect));
        items2(checkIndx) = new_index;

        % check again until all items chosen are not rated
        checkIndx = find(MR_F(nusers*(items2-1)+users)~=0);
    end
    
end

end