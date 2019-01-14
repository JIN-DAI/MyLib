function Value_k = Exponential(k, Value_1, Value_2, Step)
%EXPONENTIAL SUMMARY
% Description: Exponentially changing from Value_1 to Value_2 during Step return the value at k-th step.
% Author: Jin Dai
% Date: 2013.08.07

Value_k = Value_1 * exp((log(Value_2)-log(Value_1))*k/Step);

end

