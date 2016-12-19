function [samples, targets, s_N]=getSamples_Dxyz(path,sample_length,overlap_step,ds_rate,target_length)
%
% Create an 'samples_N * d * frames_n' training set based on translation data (Dxyz). 
% Ex: 51 joints ---> d=51*3; each 'sample' is a d*frames_N 2D matrix-- a
% sequence. A training set would be samples_N sequences.
%
%

if nargin==3
target_length=1; 
ds_rate=2;  
    
elseif nargin==2
    
overlap_step=10; 
target_length=1; 
ds_rate=2;

elseif nargin==1
        
sample_length=60; %frames in one "sample sequence"/ sequence length
overlap_step=10; % overlap_step=sample_length: no overlap;
target_length=1; % target is one frame;
ds_rate=2;

end



%path='bvh_files/01/single_file';
l=dir(path);
files_N=size(l,1)-2;

file_list=cell(files_N);

for i=1:files_N
   
    file_list{i}=strcat(path,'/',l(i+2).name);
end



%arg list


samples=[];
targets=[];
s_N=0;
for i=1:files_N
    
   fprintf('\nProcessing %s. Progress: %f%%\n',file_list{i},i/files_N);
        
    joints=loadbvh(file_list{i});
    
    frames_n=size(joints(1).Dxyz,2);

    elements_n=size(joints,2);

    d=elements_n*3; %dimensionality of an individual sequence
    
    
samples_N=floor(((frames_n-sample_length-1)/(overlap_step) +1));

frames_matrix=zeros(3*elements_n,frames_n);


    for j=1:elements_n
        if ~isempty(joints(j).rxyz)
            frames_matrix(((j-1)*3+1):(j*3),:)=joints(j).Dxyz(:,1:end);
        end

    end
    
    fprintf('Done constructing frame_matrix\n');
    
    samples_temp=zeros(samples_N,d, sample_length);
    targets_temp=zeros(samples_N,d, target_length);
    
    si=1;
    ei=si+sample_length-1;
    
    %construct design set
    
        for j=1:samples_N
          
        samples_temp(j,:,:)= frames_matrix(:,si:ei);
        targets_temp(j,:,:)= frames_matrix(:,(ei+1):(ei+target_length));
        si=si+overlap_step;
        ei=si+sample_length-1;
        

        end
s_N=s_N+samples_N;
samples=cat(1,samples,samples_temp);
targets=cat(1,targets,targets_temp);
    
    
end