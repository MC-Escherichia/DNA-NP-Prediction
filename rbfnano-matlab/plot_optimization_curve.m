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
    r = sorted(i,:)
    if v(1)==r(1) && v(3)==r(3)
        v(4) = (v(4) + r(4))/2;
    else
        reduced(n,:) = v;
        v = r;
        n = n+1;
    end

end
reduced = reduced(find(reduced(:,3)<3 ));
scatter3(reduced(:,1),reduced(:,3),reduced(:,4));
