function runRecommendations(Users, numItems, outputFile, numTestUsers,...
    filterSet,rateFunction, rateParams, N)

epsilon=10e-8;
tic;


numTestUsers=min(numTestUsers,length(Users));
fout = fopen(outputFile,'w');
for uu = 1:numTestUsers
%     fprintf('%f Iteration %d\n', toc, uu);
    u = Users(uu);
    vi = epsilon*rand(numItems,1); % to ensure random ordering of items that get same rating
    
    vi = vi+ rateFunction(u,rateParams{:});
    
    %% Step 5b Make recommendation by sorting vi
    % Remember to remove items already rated by user
    
    % remove the items already rated by u
    ratedItems = find(filterSet(u,:));
    vi(ratedItems)=-Inf;
    
    % sort the items according to vi
    [~,indx] = sort(vi,'descend');
    
    
    recommend = indx(1:N);
    %% Step 5b Write Recommendations to File
    fprintf(fout,'%d\t%d\t%e\n',[u*ones(N,1),recommend,full(vi(indx(1:N)))]');
    
end
fclose(fout);
end
