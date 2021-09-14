%% Based on Jercog et al 2017
% Permanent Up DEMO under classic homeostatic plasticity
% ssaray@ucla.edu
% dbuono@ucla.edu
%%
clear all
close all

WEE = 2.1;   
WEI = 3;    
WIE = 4;    
WII = 1.5;    

thetaE = 4.8;
thetaI = 25;
gainE = 1;
gainI = 4;

HOMEOSTATIC_FLAG = 1;
VIDEO = 0; 

testrules = 'homeo';


ExSet = 5; 
InhSet = 14; 

EvokedAmp = 7; %to elicit and up state

alpha = 0.0001; %learning rate 

tau_trial = 2 ;

E_MAX = 100; % Saturation of excitatory and inhibitory neurons
I_MAX = 250; 

WEI_MIN = 0.1;
WEE_MIN = 0.1;
WII_MIN = 0.1;
WIE_MIN = 0.1;

nTrial=500; 

savetrials=[1,140,200,302,497]; %NOTE: displayed trials numbers on the paper figure were rounded for simplicity. 


dt = 0.0001; %IN SECONDS
tmax   = 2/dt; %
%nTrial = 500; %3000
exp = 1; 
    
%HOMEOSTATIC_FLAG = 1;
GRAPHICS = 1;

learning_rule = testrules;
mkdir([learning_rule,'_demo'])

%% NETWORK PARAMETERS

F = @(x,gain,Thr) gain*max(0,x-Thr);

% % WEE = 5;    %5 2
% % WEI = 1;    %1 
% % WIE = 10;   %10 8
% % WII = 0.5;  %0.5

% thetaE = 4.8;
% thetaI = 25;
% gainE = 1;
% gainI = 4;

% W_MIN = 0.1;
% E_MAX = 100;
% I_MAX = 250;

Etau = 10/(dt*1000); %10
Itau = 2/(dt*1000);  %2

Beta = 0.0;
tauA = 500;


%Evoked: current injection to elicit a permanent Up
EvokedOn = 0.250/dt;%0.250/dt;
EvokedDur = 0.01/dt;%0.01/dt;
% EvokedAmp = 7; %7

DC =0;

hR = zeros(tmax,2); %history of Inh and Ex rate and adaptation


%% PLASTICITY STUFF


% % ExSet = 5; 
% % InhSet = 14; 

%tau_trial =2 ; %10

trial=0;
rng(42) %fixed seed


%% GRAPHICS

if GRAPHICS
    h = figure('Position',[1 1 1200 900]);
    set(gcf,'color','w');

%set(gcf,'Position',[1 1 1200 900])
%set(gcf,'Position',[1 1 800 900])

%RBmap = RedBlueColormap(3);
subplot(3,1,1)
colormap = [ 255/255,51/255,51/255; 0 0.5 0; 0 0 1];
set(gca,'colororder',colormap);
hold on
% plot(dt:dt:tmax*dt,hR,'ydatasource','hR','linewidth',3);
% line([dt tmax*dt],[ExSet ExSet],'color',[0 0.5 0],'linestyle',':','linewidth',2);
% line([dt tmax*dt],[InhSet InhSet],'color',[1 0 0],'linestyle',':','linewidth',3);
plot(dt-EvokedOn*dt:dt:tmax*dt-EvokedOn*dt,hR,'ydatasource','hR','linewidth',3);
line([dt-EvokedOn*dt tmax*dt-EvokedOn*dt],[ExSet ExSet],'color',[0 0.5 0],'linestyle','--','linewidth',2);
line([dt-EvokedOn*dt tmax*dt-EvokedOn*dt],[InhSet InhSet],'color',[255/255,51/255,51/255],'linestyle','--','linewidth',2);
%ylim([0 max(ExSet,InhSet)*2])
ylabel('E/I (Hz)')
xlabel('Time (sec)')
str = sprintf('Ex(green) Inh(red)');
%hTitle1 = title(str);
set(gca,'FontSize',20)
%set(findobj(gca,'type','line'),'linew',3)
set(gca,'linew',2)
set(gca, 'box', 'off')
ylim([0 20])
xlim([dt-EvokedOn*dt tmax*dt-EvokedOn*dt])

subplot(3,1,2)
plot(zeros(nTrial,1),'color',[255/255,51/255,51/255],'ydatasource','trialhistFCaInh','linewidth',3);
hold on
plot(zeros(nTrial,1),'color',[0 0.5 0],'ydatasource','trialhistFCa','linewidth',3);
line([1 nTrial],[ExSet ExSet],'color',[0 0.5 0],'linestyle','--','linewidth',2);
line([1 nTrial],[InhSet InhSet],'color',[255/255,51/255,51/255],'linestyle','--','linewidth',2);
%ylim([0 max(ExSet,InhSet)*3])
ylabel('Mean E/I (Hz)')
set(gca,'FontSize',20)
%set(findobj(gca,'type','line'),'linew',3)
set(gca,'linew',2)
set(gca, 'box', 'off')
ylim([0 20])


subplot(3,1,3)
plot(zeros(nTrial,1),'color',[18/255, 181/255, 143/255],'ydatasource','trialhistWEE','linewidth',3);
hold on
plot(zeros(nTrial,1),'color',[18/255, 181/255, 143/255],'ydatasource','trialhistWEI','linestyle',':','linewidth',3);
plot(zeros(nTrial,1),'color',[217/255, 68/255, 220/255],'ydatasource','trialhistWIE','linewidth',3);
plot(zeros(nTrial,1),'color',[217/255, 68/255, 220/255],'ydatasource','trialhistWII','linestyle',':','linewidth',3);
xlim([0 nTrial])
ylabel('Weights')
xlabel('Trials')
str = sprintf('g-=WEE g:=WEI m-=WIE m:=WII');
legend('WEE','WEI','WIE','WII')
%hTitle3 = title(str);
set(gca,'FontSize',20)
%set(findobj(gca,'type','line'),'linew',3)
set(gca,'linew',2)
set(gca, 'box', 'off')
legend('WEE','WEI','WIE','WII','LineWidth',1)
ylim([0 6.5])


end

%%
tic

for exp=1:exp
    
 %% Trial history variables

trialhistFCa      = NaN(nTrial,1);
trialhistFCaInh   = NaN(nTrial,1);
trialhistWEE      = NaN(nTrial,1);
trialhistWEI      = NaN(nTrial,1);
trialhistWIE      = NaN(nTrial,1);
trialhistWII      = NaN(nTrial,1);  

%% Init Variables

WInit = [WEE WEI WIE WII];
   
ExAvg = 0;
InhAvg = 0;
      
% Ornstein Uhlenbeck Noise
OUtau = 0.1;
OUmu = 0;
OUsigma = 0.1; %sigma * sqrt(dt)
OUE = 0;
OUI = 0;


hR = zeros(tmax,2); %history of Inh and Ex rate and adaptation

counter = 0;  

    for trial=1:nTrial
      
      
      E = 0;
      I = 0;
      a = 0;
      
      
      fCa = zeros(1,tmax);  %instantaneous fast Ca sensor
      fCaInh = zeros(1,tmax);  %instantaneous fast Ca sensor
      
      evoked = zeros(1,tmax);
      evoked(EvokedOn:EvokedOn+EvokedDur)=EvokedAmp;

      
      hR = zeros(tmax,2); %history of Inh and Ex rate and adaptation
      
      for t=1:tmax
         
         
         
         OUE = OUE + OUtau*(OUmu-OUE) + OUsigma*randn; %Ornstein-Uhlenbeck Noise for excitatory unit
         OUI = OUI + OUtau*(OUmu-OUI) + OUsigma*randn; %Ornstein-Uhlenbeck Noise for inhibitory unit
         
         E = E + (-E + F(WEE*E - WEI*I - a + evoked(t) + OUE + DC ,gainE,thetaE) )/Etau;
         I = I + (-I + F(WIE*E - WII*I + OUI,gainI,thetaI) )/Itau;
          
         if E>E_MAX; E = E_MAX; end
         if I>I_MAX; I = I_MAX; end
          
         % Ex Ca Sensors
         fCa(:,t) = E;
         fCaInh(:,t) = I;
         

         hR(t,:) = [I E];
         
      end
      
      
      %% HOMEOSTASIS
      
         ExAvg    = ExAvg  + (-ExAvg  + mean(fCa((end-0.5/dt):end)))/tau_trial;
         InhAvg   = InhAvg + (-InhAvg + mean(fCaInh((end-0.5/dt):end)))/tau_trial;
      
         
      if HOMEOSTATIC_FLAG
          
          EAvg =  max(1,ExAvg); %Presynaptic factor on the rules is rectified with a minimum value. 
          IAvg = max(1,InhAvg); 
          
            newWEE = WEE + alpha*EAvg*(ExSet-EAvg);
            newWEI = WEI - alpha*IAvg*(ExSet-EAvg);
            newWIE = WIE + alpha*EAvg*(InhSet-IAvg); 
            newWII = WII - alpha*IAvg*(InhSet-IAvg); 
         
         WEE = newWEE; WEI = newWEI; WIE = newWIE; WII = newWII;
         
         if WEE<WEE_MIN; WEE = WEE_MIN; end
         if WEI<WEI_MIN; WEI = WEI_MIN; end
         if WIE<WIE_MIN; WIE = WIE_MIN; end
         if WII<WII_MIN; WII = WII_MIN; end
      
      end
      
      
      trialhistFCa(trial) = ExAvg;
      trialhistFCaInh(trial) = InhAvg;
      trialhistWEE(trial) = WEE;
      trialhistWEI(trial) = WEI;
      trialhistWIE(trial) = WIE;
      trialhistWII(trial) = WII;
      
      if GRAPHICS %&& rem(trial,10)==0
      %str = sprintf('%3d| ExAvg=%4.2f(%4.2f)',trial,ExAvg,ExSet);
      %set(hTitle1,'string',str)
      %str = sprintf('WEE=%6.2f WEI=%6.2f WIE=%6.2f WII=%6.2f',WEE,WEI,WIE,WII);
      %set(hTitle3,'string',str)
      refreshdata %refresh graphics
      drawnow
        if ismember(trial,savetrials)
            saveas(gcf,[learning_rule,'_demo','/temp','Ex',num2str(ExSet),'Inh',num2str(InhSet),'Trial',num2str(trial)],'tiff') 
            saveas(gcf,[learning_rule,'_demo','/temp','Ex',num2str(ExSet),'Inh',num2str(InhSet),'Trial',num2str(trial)],'epsc') 
        end
        
      end
      if VIDEO
      counter = counter+1;
      frames(counter) = getframe(h); 
      end
   end
   
   META(exp).WInit = WInit;
   META(exp).WFinal = [WEE WEI WIE WII];
   META(exp).Trace = hR;
   META(exp).trialhistFCa = trialhistFCa;
   META(exp).trialhistFCaInh = trialhistFCaInh;
   META(exp).trialhistWEE = trialhistWEE;
   META(exp).trialhistWEI = trialhistWEI;
   META(exp).trialhistWIE = trialhistWIE;
   META(exp).trialhistWII = trialhistWII;

   
   if VIDEO
    video = VideoWriter([learning_rule,'_demo','/exp',num2str(exp)]);
    video.FrameRate = 10; %20
    open(video)
    writeVideo(video,frames);
    close(video)
    clear video
    clear frames
   end
end
toc
save([learning_rule,'_demo','/temp','Ex',num2str(ExSet),'Inh',num2str(InhSet)])
