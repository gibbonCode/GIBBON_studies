clear; close all; clc;

%Plot colors
blue=[0, 0.4470, 0.7410];
green = 1/255*[0,104,87];
gray = 1/255*[200,200,200];
yellow=[0.9290,0.6940, 0.1250];
red=[0.6350, 0.0780, 0.1840];
orange=[0.8500, 0.3250, 0.0980];


%% Control parameters

% Path names
defaultFolder = fileparts(fileparts(mfilename('fullpath')));
pathName=fullfile(defaultFolder,'2022_Maria_Gomez_Cerezo_NPerevoshchikova_PET_scaffold','data','mat_prop','PET');

%
FileList = dir(fullfile(pathName,'*.csv'));

%Raw data
time={};%seconds
disp={};%mm
force={};%N
%
interpDim=2;
n=1000;

count=1;
for iFile = 1:numel(FileList)

    Matrix_origin_table=readtable(fullfile(FileList(iFile).folder,FileList(iFile).name), 'HeaderLines',2);
    Matrix_origin = table2array(Matrix_origin_table);
    
    x_time=linspace(min(Matrix_origin(:,5)),max(Matrix_origin(:,5)),n);
    %x_time=linspace(0,100,n);
    disp = interp1_ND(Matrix_origin(:,5),Matrix_origin(:,1),x_time,interpDim,'linear');
    force = interp1_ND(Matrix_origin(:,5),Matrix_origin(:,2),x_time,interpDim,'linear');
    
% 
%     cFigure;hold on;
%     plot(Matrix_origin(:,5),Matrix_origin(:,2),'k.-','LineWidth',3);
%     plot(x_time,force,'r.-','LineWidth',1);
%     xlabel('time (s)');
%     ylabel('force (N)');
%     set(gca,'FontSize',40);camlight headlight;
%     drawnow;
    
    Mf_time{count}=x_time;
    Mf_disp{count}=disp;
    Mf_force{count}=force;

count=count+1;
end

Mat_time= vertcat(Mf_time{:})';
Mat_disp= vertcat(Mf_disp{:})';
Mat_force= vertcat(Mf_force{:})';

Mat_time=Mat_time-min(Mat_time);        
Mat_disp=Mat_disp-min(Mat_disp);
Mat_force=Mat_force-min(Mat_force);
%Calculate the standard deviation along each row.
err_force = std(Mat_force,[],2)/sqrt(size(Mat_force,2)); 

%Calculate average for each raw in cell matrices
Mat_time_av=mean(Mat_time, 2);
Mat_disp_av= mean(Mat_disp, 2);
Mat_force_av= mean(Mat_force, 2);

%Calculate the standard deviation along each row.
err_force = std(Mat_force,[],2)/sqrt(size(Mat_force,2)); 
curve1=Mat_force_av+err_force;
curve2=Mat_force_av-err_force;
x1=Mat_disp_av;
x2=Mat_disp_av;
xt1 = x1(1):x1(2)-x1(1):x1(end);
xt2 = x2(1):x2(2)-x2(1):x2(end);
f1 = spline(x1,curve1,xt1);
f2 = spline(x2,curve2,xt2);


cFigure;hold on;
hl(1)=plot(Mat_disp(:,1),Mat_force(:,1),'k.-','LineWidth',1);
plot(Mat_disp,Mat_force,'k.-','LineWidth',1);
hl(2)=plot(Mat_disp_av,Mat_force_av,'Color',blue,'LineWidth',4);
%plot(x1, curve1, 'Color',red,'LineWidth',4);
%plot(x2, curve2, 'Color',green,'LineWidth',4);
patch([xt1 fliplr(xt2)], [f1 fliplr(f2)],0.5.*ones(1,3),'FaceAlpha',0.2,'EdgeColor','None')
xlabel('Displacement (mm)');
ylabel('Force (N)');
legend(hl,{'Samples 1-5','Average data'},'FontSize',40);
set(gca,'FontSize',40);camlight headlight;
drawnow;
%
%Select elastic region
k=1;
for i=1:size(Mat_force_av,1)-1
    if (k==1)&&(Mat_force_av(i+1)-Mat_force_av(i))<0
        index=i;k=k+1;
    end
end

curve1=curve1(1:index+2);
curve2=curve2(1:index+2);
x1=Mat_disp_av(1:index+2);
x2=Mat_disp_av(1:index+2);
xt1 = x1(1):x1(2)-x1(1):x1(end);
xt2 = x2(1):x2(2)-x2(1):x2(end);
f1 = spline(x1,curve1,xt1);
f2 = spline(x2,curve2,xt2);

Mat_force_av=Mat_force_av(1:index);
Mat_disp_av=Mat_disp_av(1:index);

cFigure;hold on;
plot(Mat_disp_av,Mat_force_av,'Color',blue,'LineWidth',4);

patch([xt1 fliplr(xt2)], [f1 fliplr(f2)],0.5.*ones(1,3),'FaceAlpha',0.2,'EdgeColor','None')
xlabel('Displacement (mm)');
ylabel('Force (N)');
set(gca,'FontSize',40);camlight headlight;
drawnow;

matname = fullfile(pathName,'PET.mat');
save(matname,'Mat_time_av','Mat_disp_av','Mat_force_av','xt1','xt2','f1','f2');


