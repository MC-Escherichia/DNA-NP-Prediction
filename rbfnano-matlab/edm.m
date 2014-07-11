   function z = edm(w,p)
        [S,R]=size(w);
        [Q,R2] = size(p);
        p = p';
      if(R~=R2), error('Inner matrix dimensions do not match.\n') , end
        
      z = zeros(S,Q);
      if (Q<S)
          p = p';
         copies = zeros(1,S); 
         for q=1:Q
             z(:,q) = sum((w-p(q+copies,:)).^2,2);
         end 
      else
          w = w';
         copies = zeros(1,Q); 
         for i=1:S
             z(i,:) = sum((w(:,i+copies)-p).^2,1);
         end 
      end
      z = z.^0.5;    
    end
