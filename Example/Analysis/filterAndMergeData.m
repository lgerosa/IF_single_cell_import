function [DataP1234] = filterAndMergeData()
%FILTERANDMERGEDATA gates the two datasets and merges them in a unique dataset 

%% load the two data sets and concatenate in one table
load('..\Data_20180320_P1\Data.mat');
DataP1234=Data;
load('..\Data_20180320_P2\Data.mat');
DataP1234=[DataP1234; Data];
load('..\Data_20180320_P3\Data.mat');
DataP1234=[DataP1234; Data];
load('..\Data_20180320_P4\Data.mat');
DataP1234=[DataP1234; Data];

save DataP1234 DataP1234;


end

