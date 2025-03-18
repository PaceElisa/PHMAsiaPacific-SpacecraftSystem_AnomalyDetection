function XTable = fitrgpConditionalConstraints4(XTable)
% Conditional constraints function for Regression GPR model
%
%  Input:
%      XTable: A table of hyperparameter values to try during the Bayesian
%       optimization process. Each row corresponds to one point, and each
%       column corresponds to one hyperparameter.
%  Output:
%      XTable: A table of hyperparameter values to try during the Bayesian
%       optimization process. The values are adjusted according to the
%       constraint function rules.
%
% Conditional constraints enforce one of the following two conditions:
% 1. When some hyperparameters have certain values, other hyperparameters
% are set to given values.
%  2. When some hyperparameters have certain values, other hyperparameters
%  are set to NaN or, for categorical hyperparameters, <undefined> values.
%
% Refer to the documentation for more information on <a href="matlab:helpview('stats', 'bayesopt_conditional_constraints')">conditional
% constraints</a> in Bayesian optimization.

% Auto-generated by MATLAB on 16-Mar-2025 14:08:06

% Set KernelScale to NaN when KernelFunction is any ARD kernel
if hasVariables(XTable, {'KernelScale', 'KernelFunction'})
    ARDRows = ismember(XTable.KernelFunction, {'ardexponential','ardmatern32','ardmatern52','ardrationalquadratic','ardsquaredexponential'});
    XTable.KernelScale(ARDRows) = NaN;
end
end

function tf = hasVariables(Tbl, VarNames)
% Return true if table Tbl has all variables VarNames.
tf = all(ismember(VarNames, Tbl.Properties.VariableNames));
end