function scores = fitnessEvaluation(params)
function s = score(k, dev, r)
NPobt = crystalData.NParr{k};
NNobt = crystalData.NNarr{k};
s = norm(NNdes-NNobt) + norm(NPdes-NPobt) + asym(dev) + enDiff(r);
end
function [kmin, dev, r] = memomodel(params)
key = mat2str(params);
if ~isempty(params) && memoDB.containsKey(key)
    val = memoDB.get(key);
    kmin = val(1);
    dev = val(2);
    r = val(3);
else
    dna_ratio = params(1);
    size_ratio = params(2);
    rho_AA = params(3);
    rho_BB = params(4);
    NP_expA = params(5);
    NP_expB = params(6);
    comp = params(7);
    [kmin,E,dev,E2] = CCM_NNfull(dna_ratio,size_ratio,rho_AA,rho_BB,sigma,[NP_expA,NP_expB],comp);
    r = E2./E;
    memoDB.putIfAbsent(key,[kmin,dev,r])
end
end


[kmin, dev, r] = memomodel(params);

scores = score(kmin,dev,r);


end