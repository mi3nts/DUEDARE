function [In_Train,Out_Train,In_Validation,Out_Validation]=representative_sample(In,Out,pvalid,nbins_per_column,n_per_bin)

% Create an array of all the data
D=[In Out];

% Find size of D
n=size(D);
nrows=n(1);
ncols=n(2);

%--------------------------------------------------------------------------
% Go through each column and choose a representative sample.
ikeep_train=[];
ikeep_valid=[];
for icol=1:ncols
    
    %--------------------------------------------------------------------------
    % Take a copy of this coulumn
    this_col=D(:,icol);
    
    nunique_this_col=length(unique(this_col));
    
    % Number of bins per column (variable)
    nbins_this_column=min([nbins_per_column nunique_this_col]);
    n_per_thisbin=n_per_bin;
    
    % For the output variable have more bins.
    if icol==ncols
        nbins_this_column=min([nbins_this_column*10 nunique_this_col]);
        n_per_thisbin=n_per_bin*10;
    end
    
    disp([...
        'Going through column ' num2str(icol) ...
        ' and choosing a representative sample. Choosing ' ...
        num2str(nbins_this_column) ' bins for this column. With ' ...
        num2str(n_per_thisbin) ' members per bin.' ...
        ])
    

    %--------------------------------------------------------------------------
    % For this column split into nbins_per_column
    % returns an index array, bin, using any of the previous syntaxes. 
    % bin is an array of the same size as X whose elements are the bin 
    % indices for the corresponding elements in X. 
    % The number of elements in the kth bin is nnz(bin==k), 
    % which is the same as N(k).
    [N,edges,bin] = histcounts(this_col,nbins_this_column); 
    
    % loop over the bins
    for ibin=1:nbins_this_column
        
        clear ikeep_this_bin nkeep_this_bin iwant_ibin nwant_ibin ...
            nchoose_this_bin ipoint_this_bin
        
        % find which indices are in this bin
        iwant_ibin=find(bin==ibin);
        
        % find the number of points in this bin
        nwant_ibin=length(iwant_ibin);
        
        % take a random sample of n_per_bin from each bin
        nchoose_this_bin=min([n_per_thisbin nwant_ibin]);
        
        % Find the indices of the actual data records
        ipoint_this_bin=randperm(nwant_ibin,nchoose_this_bin);
        
        % Add these to the list of records we will be keeping
        ikeep_this_bin=iwant_ibin(ipoint_this_bin);
        nkeep_this_bin=length(ikeep_this_bin);
        
        % Number of validation points for this bin
        nvalid_this_bin=floor(pvalid*nkeep_this_bin);
        if nvalid_this_bin>1
            ikeep_valid=cat(1,ikeep_valid,ikeep_this_bin(1:nvalid_this_bin));
            ikeep_train=cat(1,ikeep_train,ikeep_this_bin(nvalid_this_bin+1:end));
            %disp(['length(ikeep_valid) = ' num2str(length(ikeep_valid))])
            %disp(['length(ikeep_train) = ' num2str(length(ikeep_train))])
        else
            ikeep_train=cat(1,ikeep_train,ikeep_this_bin);
        end
        
    end
    % loop over the bins
    %--------------------------------------------------------------------------
    %length(ikeep)
    
end
% Go through each column and choose a representative sample.
%--------------------------------------------------------------------------

% find the records common to both the training and validation dataset and
% delete them
iboth=intersect(ikeep_train,ikeep_valid);
disp(['# of records in both training and validation datasets is ' num2str(length(iboth))])
ideleteboth=ismember(ikeep_valid,iboth);
ikeep_valid(find(ideleteboth))=[];

% make sure we do not have duplicate records.
disp('Make sure we do not have duplicate records.')
disp(['The initial number of records we have kept for training is ' separatethousands(length(ikeep_train),',',0) ])
ikeep_train=unique(ikeep_train);
nkeep_train=length(ikeep_train);
disp(['The number of unique records we have kept for training is ' separatethousands(nkeep_train,',',0) ])
In_Train=In(ikeep_train,:);
Out_Train=Out(ikeep_train);
whos *_Train

disp(['The initial number of records we have kept for validation is ' separatethousands(length(ikeep_valid),',',0) ])
ikeep_valid=unique(ikeep_valid);
nkeep_valid=length(ikeep_valid);
disp(['The number of unique records we have kept for validation is ' separatethousands(nkeep_valid,',',0) ])
In_Validation=In(ikeep_valid,:);
Out_Validation=Out(ikeep_valid);
whos *_Validation