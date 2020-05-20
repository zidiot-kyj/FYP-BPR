# FYP-BPR

Project title: Bayesian Personalised Ranking for Accuracy, Diversity and Pairwise Recommendations

Student name: Youjie Kang    
Supervisor: Neil Hurley

The code implements a Top-10 BPR recommender model, 
which recommends a set of 10 items that are likely to be most satisfying to specific users. 

In the code folder, there is a script called ‘FYP_TEST.m’ which can be run to execute the code and evaluate the model.
In this script, it calls the function ‘drive.m’, and requires a datafile called ‘mlNew.csv’ which is also in the code folder.
The recommendation lists are written into a file called ‘recs.dat’ by the program.
In addition, the program outputs a matrix, which indicates all the corresponding performance metrics,
including precision, diversity, and popular bias.

To be more specific, in the script ‘FYP_TEST.m’, 
users can set the range and step of the learning rate parameter and regularization parameters. 
Also, they can choose one sampling strategy for implementation by changing the value of variable "chooseSam":    
1: Random-basic Sampler  
2: Sampler_MBP  
3: Sampler_MIP  
4: Sampler_LP   
5: Sampler_MS   
6: Sampler_LS   
7: Sampler_Combination   

In the function 'drive.m',
it calls function 'initialization.m' to generate training set, test set, popularity vector and similarity matrix in advance.
Then, it can conduct parameter optimization based on the input.
In each cycle, the program conducts 5-fold cross-validation.
It calls function 'BPR.m' and 'runRecommendations.m' to apply the recommender model and generate the recommendation list.
Finally, it calls function 'aggregatePerf.m' to estimate the corresponding precision, diversity and popular bias.

