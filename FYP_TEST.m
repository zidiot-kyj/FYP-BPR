% FYP_TEST
clear;

% set the range of learning rate parameter alpha,
% and the regularization parameters lambdap, lambdaq
a_max = 0.1;
a_min = 0;
p_max = 0.05;
p_min = 0;
q_max = 0.05;
q_min = 0;

% set the step for parameter optimizations
s1 = 5;
s2 = 5;
s3 = 5;

% use "chooseSam" to choose the sampling strategy
% 1: Random-basic Sampler
% 2: Sampler_MBP
% 3: Sampler_MIP
% 4: Sampler_LP
% 5: Sampler_MS
% 6: Sampler_LS
% 7: Sampler_Combination
chooseSam = 1;

% the recommendation list is generated in function "drive"
% and stored in 'recs.dat';
% the output_matrix shows precision, diversity, and popularity bias for
% the recommendation list
[output_matrix]=drive('mlNew.csv', a_max, a_min, p_max, p_min, q_max, q_min, s1, s2, s3, chooseSam);
