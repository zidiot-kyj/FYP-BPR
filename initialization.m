function [p,Data_SIM,Data_NOR,Data_train,Data_validation,Data_MR]=initialization(datafile)

% load data
Y = load(datafile);

%% calculate popularity for items

items = Y(:,2);
n = max(items);

count = zeros(n,1);
for i = 1:length(items)
   count(items(i))= count(items(i))+1;
end

max_p = max(count);
min_p = min(count);

popularity = (count-min_p)/(max_p-min_p);

%% divide the dataset into training set, validation set and text set

% Originally, testsplit = 0.1
testsplit = 0.1;

splitsize = ceil(size(Y,1)*(1.0-testsplit));

% create a random permutation of the data
p = randperm(size(Y,1));

% randomly select the data items to place in train & validation and test

Ytest = Y(p((splitsize+1):end),:);
Ytest = sparse(Ytest(:,1),Ytest(:,2),Ytest(:,3));

% Yt_v = Y(p(1:splitsize),:);
Yt_v = Y;

% Originally, subtestsplit = 0.8

subtestsplit = 0.8;
subsplitsize = ceil(size(Yt_v,1)*(1.0-subtestsplit));

p2 = randperm(size(Yt_v,1));

% 1st case
Yvalidation0 = Yt_v(p2(1:subsplitsize),:);
Ytrain0 = Yt_v(p2((subsplitsize+1):end),:);
Yvalidation0 = sparse(Yvalidation0(:,1),Yvalidation0(:,2),Yvalidation0(:,3));
Ytrain0 = sparse(Ytrain0(:,1),Ytrain0(:,2),Ytrain0(:,3));

% 2nd case
Yvalidation1 = Yt_v(p2((subsplitsize+1):(subsplitsize+subsplitsize)),:);
Y1 = Yt_v(p2(1:(subsplitsize)),:);
Y2 = Yt_v(p2((subsplitsize+subsplitsize+1):end),:);
Ytrain1 = [Y1;Y2];
Yvalidation1 = sparse(Yvalidation1(:,1),Yvalidation1(:,2),Yvalidation1(:,3));
Ytrain1 = sparse(Ytrain1(:,1),Ytrain1(:,2),Ytrain1(:,3));
        
% 3rd case
Yvalidation2 = Yt_v(p2((subsplitsize*2+1):(subsplitsize*2+subsplitsize)),:);
Y3 = Yt_v(p2(1:(subsplitsize*2)),:);
Y4 = Yt_v(p2((subsplitsize*2+subsplitsize+1):end),:);
Ytrain2 = [Y3;Y4];
Yvalidation2 = sparse(Yvalidation2(:,1),Yvalidation2(:,2),Yvalidation2(:,3));
Ytrain2 = sparse(Ytrain2(:,1),Ytrain2(:,2),Ytrain2(:,3));
        
% 4th case
Yvalidation3 = Yt_v(p2((subsplitsize*3+1):(subsplitsize*3+subsplitsize)),:);
Y5 = Yt_v(p2(1:(subsplitsize*3)),:);
Y6 = Yt_v(p2((subsplitsize*3+subsplitsize+1):end),:);
Ytrain3 = [Y5;Y6];
Yvalidation3 = sparse(Yvalidation3(:,1),Yvalidation3(:,2),Yvalidation3(:,3));
Ytrain3 = sparse(Ytrain3(:,1),Ytrain3(:,2),Ytrain3(:,3));
        
% 5th case
Yvalidation4 = Yt_v(p2((4*subsplitsize+1):end),:);
Ytrain4 = Yt_v(p2(1:(4*subsplitsize)),:); 
Yvalidation4 = sparse(Yvalidation4(:,1),Yvalidation4(:,2),Yvalidation4(:,3));
Ytrain4 = sparse(Ytrain4(:,1),Ytrain4(:,2),Ytrain4(:,3));

%% calculate similarity

nitems0 = size(Ytrain0,2); % number of items
nitems1 = size(Ytrain1,2); % number of items
nitems2 = size(Ytrain2,2); % number of items
nitems3 = size(Ytrain3,2); % number of items
nitems4 = size(Ytrain4,2); % number of items

[i0,j0,v0]=find(Ytrain0);
[i1,j1,v1]=find(Ytrain1);
[i2,j2,v2]=find(Ytrain2);
[i3,j3,v3]=find(Ytrain3);
[i4,j4,v4]=find(Ytrain4);
R0 = [i0,j0,v0];
R1 = [i1,j1,v1];
R2 = [i2,j2,v2];
R3 = [i3,j3,v3];
R4 = [i4,j4,v4];

MR0 = sparse(R0(:,1),R0(:,2),R0(:,3));
MR1 = sparse(R1(:,1),R1(:,2),R1(:,3));
MR2 = sparse(R2(:,1),R2(:,2),R2(:,3));
MR3 = sparse(R3(:,1),R3(:,2),R3(:,3));
MR4 = sparse(R4(:,1),R4(:,2),R4(:,3));
SIM0 = MR0'*MR0;
SIM1 = MR1'*MR1;
SIM2 = MR2'*MR2;
SIM3 = MR3'*MR3;
SIM4 = MR4'*MR4;

INI_SIM0 = ones(nitems0,nitems0);
INI_SIM1 = ones(nitems1,nitems1);
INI_SIM2 = ones(nitems2,nitems2);
INI_SIM3 = ones(nitems3,nitems3);
INI_SIM4 = ones(nitems4,nitems4);

for i = 1:nitems0
    for j = 1:nitems0
        indx0_1 = find(MR0(:,i)~=0);
        indx0_2 = find(MR0(:,j)~=0);
        INI_SIM0(i,j) = length(intersect(indx0_1,indx0_2));
    end
end

0

for i = 1:nitems1
    for j = 1:nitems1
        indx1_1 = find(MR1(:,i)~=0);
        indx1_2 = find(MR1(:,j)~=0);
        INI_SIM1(i,j) = length(intersect(indx1_1,indx1_2));
    end
end

1

for i = 1:nitems2
    for j = 1:nitems2
        indx2_1 = find(MR2(:,i)~=0);
        indx2_2 = find(MR2(:,j)~=0);
        INI_SIM2(i,j) = length(intersect(indx2_1,indx2_2));
    end
end

2

for i = 1:nitems3
    for j = 1:nitems3
        indx3_1 = find(MR3(:,i)~=0);
        indx3_2 = find(MR3(:,j)~=0);
        INI_SIM3(i,j) = length(intersect(indx3_1,indx3_2));
    end
end

3

for i = 1:nitems4
    for j = 1:nitems4
        indx4_1 = find(MR4(:,i)~=0);
        indx4_2 = find(MR4(:,j)~=0);
        INI_SIM4(i,j) = length(intersect(indx4_1,indx4_2));
    end
end

4

SIM0_2 = SIM0./(INI_SIM0+0.000001);
SIM1_2 = SIM1./(INI_SIM1+0.000001);
SIM2_2 = SIM2./(INI_SIM2+0.000001);
SIM3_2 = SIM3./(INI_SIM3+0.000001);
SIM4_2 = SIM4./(INI_SIM4+0.000001);

AVE0 = mean(mean(SIM0_2));
AVE1 = mean(mean(SIM1_2));
AVE2 = mean(mean(SIM2_2));
AVE3 = mean(mean(SIM3_2));
AVE4 = mean(mean(SIM4_2));

FIN_SIM0 = abs(SIM0_2-AVE0);
FIN_SIM1 = abs(SIM1_2-AVE1);
FIN_SIM2 = abs(SIM2_2-AVE2);
FIN_SIM3 = abs(SIM3_2-AVE3);
FIN_SIM4 = abs(SIM4_2-AVE4);

max_sim0 = max(max(FIN_SIM0));
min_sim0 = min(min(FIN_SIM0));
NOR_SIM0 = (FIN_SIM0-min_sim0)/(max_sim0-min_sim0);

max_sim1 = max(max(FIN_SIM1));
min_sim1 = min(min(FIN_SIM1));
NOR_SIM1 = (FIN_SIM1-min_sim1)/(max_sim1-min_sim1);

max_sim2 = max(max(FIN_SIM2));
min_sim2 = min(min(FIN_SIM2));
NOR_SIM2 = (FIN_SIM2-min_sim2)/(max_sim2-min_sim2);

max_sim3 = max(max(FIN_SIM3));
min_sim3 = min(min(FIN_SIM3));
NOR_SIM3 = (FIN_SIM3-min_sim3)/(max_sim3-min_sim3);

max_sim4 = max(max(FIN_SIM4));
min_sim4 = min(min(FIN_SIM4));
NOR_SIM4 = (FIN_SIM4-min_sim4)/(max_sim4-min_sim4);

%% define output

Data_SIM{1}=FIN_SIM0;
Data_SIM{2}=FIN_SIM1;
Data_SIM{3}=FIN_SIM2;
Data_SIM{4}=FIN_SIM3;
Data_SIM{5}=FIN_SIM4;

Data_NOR{1}=NOR_SIM0;
Data_NOR{2}=NOR_SIM1;
Data_NOR{3}=NOR_SIM2;
Data_NOR{4}=NOR_SIM3;
Data_NOR{5}=NOR_SIM4;

Data_train{1} = Ytrain0;
Data_train{2} = Ytrain1;
Data_train{3} = Ytrain2;
Data_train{4} = Ytrain3;
Data_train{5} = Ytrain4;

Data_validation{1} = Yvalidation0;
Data_validation{2} = Yvalidation1;
Data_validation{3} = Yvalidation2;
Data_validation{4} = Yvalidation3;
Data_validation{5} = Yvalidation4;

Data_MR{1}= MR0;
Data_MR{2}= MR1;
Data_MR{3}= MR2;
Data_MR{4}= MR3;
Data_MR{5}= MR4;

p = popularity;

end
