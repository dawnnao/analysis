function e = nanrms(x)
% nanrms(x) root-mean-square ignoring NaN values

e = sqrt(nanmean(x.^2));
end