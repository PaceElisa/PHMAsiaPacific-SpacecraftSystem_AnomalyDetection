function TF = fitcensembleDeterministicConstraints1(XTable)
% Deterministic constraints function for Classification Ensemble model
%
%  Input:
%      XTable: A table of hyperparameter values to try during the Bayesian
%       optimization process. Each row corresponds to one point, and each
%       column corresponds to one hyperparameter.
%  Output:
%      TF: A logical column vector, where TF(i) is true when the point with
%       hyperparameter values XTable(i,:) is feasible.
%
% A deterministic constraints function returns a true value when a point in
% the hyperparameter search space is feasible (that is, the problem is
% valid or well-defined at this point) and a false value otherwise.
%
% Refer to the documentation for more information on <a href="matlab:helpview('stats', 'bayesopt_deterministic_constraints')">deterministic
% constraints</a> in Bayesian optimization.

% Auto-generated by MATLAB on 17-Feb-2025 22:25:44

xConstraintFcn = [];
TF = true(height(XTable),1);
% Apply the weak learner's deterministic constraints function
if ~isempty(xConstraintFcn)
    TF = TF & xConstraintFcn(XTable);
end
end


function tf = hasVariables(Tbl, VarNames)
% Return true if table Tbl has all variables VarNames.
tf = all(ismember(VarNames, Tbl.Properties.VariableNames));
end