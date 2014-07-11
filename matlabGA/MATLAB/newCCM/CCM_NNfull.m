function [kmin,E,dev,E2] = CCM_NNfull(R_l,R_s,rho_AA,rho_BB,sigma,NP_exp,comp)

global crystalData 

        E_f1 = zeros(size(crystalData.names));
        devs = zeros(size(crystalData.names));
     for k = 1:length(crystalData.names)
            
          
             [~,E_f1(k),~,devs(k),~,~] = CCM_NNmain(R_l,R_s,crystalData.NNarr{k},crystalData.NParr{k},crystalData.dists{k},rho_AA,rho_BB,sigma,NP_exp,comp,1);
                  
            
          
     end
     
     [E ,kmin] = min(E_f1);

    E2 = min(E_f1([1:kmin-1,kmin+1:end]));
    % commented code will find index of next lowest as well. 
    % [E2,k2] = min(E_f1([1:kmin-1,kmin+1:end]));
    % if k2>=kmin, k2 = k2+1; end
     
     dev = devs(kmin); 

end