function [output_matrix]=drive(datafile, a_max, a_min, p_max, p_min, q_max, q_min, s1, s2, s3, chooseSam)

% use "chooseSam" to choose the sampling strategy
% 1: Random-basic Sampler
% 2: Sampler_MBP
% 3: Sampler_MIP
% 4: Sampler_LP
% 5: Sampler_MS
% 6: Sampler_LS
% 7: Sampler_Combination

k = 20;  % number of latent factors
numTestUsers=100; % number  of users to test
N = 10;  % number of items to recommend
ratingThreshold= 1 ; % value of rating above which item is considered relevant

% Load file and initialization
[popularity,Data_SIM,Data_NOR,Data_train,Data_validation,Data_MR]=initialization(datafile);
    
% define output matrix
Output = zeros(s1*s2*s3,6);

% aim to estimate (s1*s2*s3) groups of parameters
a_rangesize = (a_max-a_min)/s1;
p_rangesize = (p_max-p_min)/s2;
q_rangesize = (q_max-q_min)/s3;

% mark the location of the specific output
index = 1;

%% parameter optimization

for alpha = (a_min+a_rangesize):a_rangesize:a_max
    for lambdaP = (p_min+p_rangesize):p_rangesize:p_max
       for lambdaQ = (q_min+q_rangesize):q_rangesize:q_max 
        
        % conduct 5-fold cross-validation
        sum_prec = 0;
        sum_div = 0;
        sum_pop = 0;
        
       for n = 1:5
            
            Yvalidation = Data_validation{n};
            Ytrain = Data_train{n};

            M = size(Ytrain,2); % total number of items
            U = size(Ytrain,1);  % total number of users

            % put the test data (validation) into the form required
            % by the aggregratePerf function
            [i,j,v]=find(Yvalidation);
            testData = [i,j,v];

            [P,Q,B] = bpr(Ytrain, k, alpha, lambdaP, lambdaQ, lambdaQ, chooseSam, Data_MR{n}, Data_SIM{n}, Data_NOR{n});

            % Use the model to make recommendations
            rateParams{1}=P;
            rateParams{2}=Q;
            rateParams{3}=B;
            rateFunction = @RFrate;

            Users=1:U;
            runRecommendations(Users, M,'recs.dat', numTestUsers,Ytrain,rateFunction, rateParams, N);
            recommendations=load('recs.dat');

            % evaluate the quslity of the recommendations using the test data
            [pop,div,mprec,sprec]=aggregatePerf(popularity,Data_NOR{n},recommendations,testData,@precision,ratingThreshold,N);
            fprintf('Mean precision=%f\tStd precision=%f\n',mprec,sprec);
           
            sum_prec = sum_prec + mprec;
            sum_div = sum_div + div;
            sum_pop = sum_pop + pop;
        end
        
            average_prec = sum_prec/5;
            average_div = sum_div/5;
            average_pop = sum_pop/5;
            
            % update the output value
            Output(index,1)= alpha;
            Output(index,2)= lambdaP;
            Output(index,3)= lambdaQ;
            Output(index,4)= average_prec;
            Output(index,5)= average_div;
            Output(index,6)= average_pop;
            index = index + 1
            
       end
    end  
end

output_matrix = Output;

end

