function [train_ind,val_ind,test_ind] = sampledata(X,Y,tr_size, ...
                                                  val_size,sample_cond)

[C R]=size(X);

 success = 0;

while ~success ;
  index_mat=randperm(C);
  train_ind = index_mat(1:tr_size);
  train_y = Y(train_ind,:);

  success = sample_cond(X(train_ind),train_y);

end

val_ind = index_mat(tr_size+1:tr_size+val_size);
test_ind = index_mat(tr_size+val_size:end);
