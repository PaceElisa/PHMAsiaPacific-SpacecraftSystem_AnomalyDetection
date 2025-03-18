clear all;

%% Final pipeline made up of all tasks' pipelines
run("task1\testing\testingPipeline.m");
all_predictions = table(prediction(:,1), prediction(:,2),'VariableNames', {'ID', 'Task1'});

run("task2\testing\testing_pipeline_2.m");
all_predictions.Task2 = table2array(predictionsTable(:,1));

run("task3\testing\testing_pipeline_3.m");
all_predictions.Task3 = table2array(predictionsTable(:,1));

run("task4\testing\testing_pipeline_4.m");
all_predictions.Task4 = table2array(predictionsTable(:,1));

run("task5\testing\testing_pipeline_5.m");
all_predictions.Task5 = table2array(predictionsTable5(:,1));


%% Calculate max score for each tasks

%task 1
score_max_task1 = 20 * sum(answers{:, 'Spacecraft No.'} == 4) + ...
                   10 * sum(answers{:, 'Spacecraft No.'} ~= 4);

%task 5
score_max_task5 = 40 * sum(answers{:, end-1} ~= 100 & answers{:, 'Spacecraft No.'} == 4) + ...
                   20 * sum(answers{:, end-1} ~= 100 & answers{:, 'Spacecraft No.'} ~= 4);

%task 2, 3 e 4
score_max_other_tasks = 20 * sum(answers{:, 4:end-2} ~= 0 & answers{:, 'Spacecraft No.'} == 4) + ...
                        10 * sum(answers{:, 4:end-2} ~= 0 & answers{:, 'Spacecraft No.'} ~= 4);


%% Metrics of Evaluation
prediction_score=0;
max_score= 0;

% task 1
score_task1 = [answers.("Spacecraft No."), (all_predictions.Task1 == answers.task1)];
prediction_score_task1 = 0;
for i=1:length(score_task1)
    if score_task1(i,2)==1
        if score_task1(i,1)==4        
            prediction_score_task1 = prediction_score_task1+20;
        else 
            prediction_score_task1 = prediction_score_task1+10;
        end
    end
end
prediction_score = prediction_score + prediction_score_task1;

disp([newline 'Final Score obtained for Task1: ', num2str(prediction_score_task1,'%.0f'),'/',num2str(score_max_task1,'%.0f')]);

%task 2
score_task2 = [answers.("Spacecraft No."), (all_predictions.Task2 == answers.task2)];
prediction_score_task2 = 0;
for i=1:length(score_task2)
    if table2array(answers(i,"task2")) ~= 0 && score_task2(i,2)==1
        if score_task2(i,1)==4        
            prediction_score_task2 = prediction_score_task2+20;
        else 
            prediction_score_task2 = prediction_score_task2+10;
        end
    end
end
prediction_score = prediction_score + prediction_score_task2;

disp(['Final Score obtained for Task2: ', num2str(prediction_score_task2,'%.0f'),'/',num2str(score_max_other_tasks(1,1),'%.0f')]);

%task 3
score_task3 = [answers.("Spacecraft No."), (all_predictions.Task3 == answers.task3)];
prediction_score_task3 = 0;
for i=1:length(score_task3)
    if table2array(answers(i,"task3")) ~= 0 && score_task3(i,2)==1
        if score_task3(i,1)==4        
            prediction_score_task3 = prediction_score_task3+20;
        else 
            prediction_score_task3 = prediction_score_task3+10;
        end
    end
end
prediction_score = prediction_score + prediction_score_task3;

disp(['Final Score obtained for Task3: ', num2str(prediction_score_task3,'%.0f'),'/',num2str(score_max_other_tasks(1,2),'%.0f')]);

%task 4
score_task4 = [answers.("Spacecraft No."), (all_predictions.Task4 == answers.task4)];
prediction_score_task4 = 0;
for i=1:length(score_task4)
    if table2array(answers(i,"task4")) ~= 0 && score_task4(i,2)==1
        if score_task4(i,1)==4        
            prediction_score_task4 = prediction_score_task4+20;
        else 
            prediction_score_task4 = prediction_score_task4+10;
        end
    end
end
prediction_score = prediction_score + prediction_score_task4;

disp(['Final Score obtained for Task4: ', num2str(prediction_score_task4,'%.0f'),'/',num2str(score_max_other_tasks(1,3),'%.0f')]);

%task 5
score_task5 = [answers.("Spacecraft No."), all_predictions.Task5, answers.task5];
prediction_score_task5 = 0;
for i=1:length(score_task5)
    if score_task5(i,3) ~= 100 
        s = max(-abs(score_task5(i,2)-score_task5(i,3))+20, 0);
        if score_task4(i,1)==4        
            prediction_score_task5 = prediction_score_task5+(s*2);
        else 
            prediction_score_task5 = prediction_score_task5+s;
        end
    end
end
prediction_score = prediction_score + prediction_score_task5;

disp(['Final Score obtained for Task5: ', num2str(prediction_score_task5,'%.0f'),'/',num2str(score_max_task5,'%.0f')]);

%% Total Score
max_score = score_max_task1 + sum(score_max_other_tasks) + score_max_task5;
disp([newline 'Final Score Obtained: ', num2str(prediction_score,'%.0f'),'/', num2str(max_score,'%.0f')]);

prediction_score = prediction_score/max_score*100;
disp(['Final Score Obtained: ', num2str(prediction_score,'%.2f'),'%']);
