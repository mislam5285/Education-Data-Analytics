
%%
function [Accuracy, Error, ResponseRate] = AccuracyRate(Origlabel, predlabel) 


% we consider non NaN only
selected = ~isnan(Origlabel) & ~isnan(predlabel);
Origlabel = Origlabel(selected);
predlabel = predlabel(selected);

%
index = ( Origlabel == predlabel );
Accuracy = sum(index)/length(index);
Error = 1 - Accuracy;

ResponseRate =  sum(selected)/numel(selected);

end