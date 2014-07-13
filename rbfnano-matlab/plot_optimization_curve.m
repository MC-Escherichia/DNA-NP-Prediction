load('results.mat'); % if error run sweep in rbf_nano.m save res
                     % variable to results


res_count = sum(cellfun(@(x) length(x)>0,res(:)));

reshaped = zeros(res_count,4);

[I J K] = size(res);
c =1;
for j = 1:J % Q index
    for k = 1:K % b index
        i = 1;
        while i<=I
            r = res{i,j,k};
            if ~isempty(r)
            reshaped(c,:) = [j k r];
            c = c+1;
            end
            i = i + 1;
        end
    end
end

sorted = sortrows(reshaped,[1 3]);


n= 1;
reduced = []

v = sorted(1,:);
for i=2:length(sorted)
    r = sorted(i,:);
    if v(1)==r(1) && v(3)==r(3)
        v(4) = (v(4) + r(4))/2;
    else
        reduced(n,:) = v;
        v = r;
        n = n+1;
    end

end



error = reduced(:,4);
clipped= reduced(find(error<0.1),:); % trying to see closer.


%% This plot is hideous, apoorv can you do any better, but X=15 and
%% s = 0.5 seem to make sense.
scatter3(clipped(:,1),clipped(:,3),clipped (:,4));
% if we want a surface plot we need to reduced cols 1 and 3 to just
% their values, and place the correspondings errors in a Z matrix,
% with NaN's for when we don't know the answe.
