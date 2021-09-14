%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Multi-unit rate-based population model with two-term homeostatic Up development rules. 
% ssaray@ucla.edu
% dbuono@ucla.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SIMULATION SETTINGS %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

dt = 0.0001; %IN SECONDS
tmax   = 2/dt; %
nTrial = 200; %100

rng(44)
    
GRAPHICS = 1;
VIDEO =0;
HOMEOSTATIC_FLAG = 1;


learning_rule= 'two-term'; 

savetrials = [1,2,5,40,200]; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NEURON PARAMETERS %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F = @(x,gain,Thr) gain*max(0,x-Thr);

Ne = 80;
Ni = 20;

thetaE = 4.8;
thetaI = 25;
gainE = 1;
gainI = 4;

Etau = 10/(dt*1000); 
Itau = 2/(dt*1000);  

Beta = 0;
tauA = 500;

E_MAX = 100;
I_MAX = 250;

OUtau = 0.1; %Ornstein-Uhlenbeck Noise
OUmu = 0;
OUsigma = 0.1; % sigma * sqrt(dt)

OUE = zeros(Ne,1);
OUI = zeros(Ni,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INIT WEIGHT MATRIX %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WEE = rand(Ne,Ne)*0.16; 
WEE = WEE - diag(diag(WEE));

WEI = rand(Ne,Ni)*0.16;

WIE= rand(Ni,Ne)*0.16;

WII = rand(Ni,Ni)*0.16;
WII = WII - diag(diag(WII));

%%
Winit = [WEE,WEI;WIE,WII];

WEEp = sum(WEE,2);
WEIp = sum(WEI,2);
WIEp = sum(WIE,2);
WIIp = sum(WII,2);

initWEEp = WEEp;
initWEIp = WEIp;
initWIEp = WIEp;
initWIIp = WIIp;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLASTICITY %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ExSet = 5; %setpoint for excitatory neurons
InhSet = 14; %setpoint for inhibitory neurons

tau_trial = 2 ;

WEI_MIN = 0.1;
WEE_MIN = 0.1;
WII_MIN = 0.1;
WIE_MIN = 0.1;

alpha = 0.00001; %learning rate 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INIT VARS %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialhistFCa      = NaN(nTrial,Ne);
trialhistFCaInh   = NaN(nTrial,Ni);
trialhistWEE      = NaN(nTrial,Ne);
trialhistWEI      = NaN(nTrial,Ne);
trialhistWIE      = NaN(nTrial,Ni);
trialhistWII      = NaN(nTrial,Ni);  
trialhistWEEp      = NaN(nTrial,Ne);
trialhistWEIp      = NaN(nTrial,Ne);
trialhistWIEp      = NaN(nTrial,Ni);
trialhistWIIp      = NaN(nTrial,Ni);  

ExAvg = zeros(Ne,1);
InhAvg = zeros(Ni,1);

hR = zeros(tmax,Ne+Ni); %history of Inh and Ex rate 


EvokedOn = 0.250/dt; %Evoked current
EvokedDur = 0.01/dt; 
EvokedAmp = 7; 

counter = 0;  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if GRAPHICS
    Fig6_two_term_demo_multi_unit_graphics
end

if VIDEO
      counter = counter+1;
      frames(counter) = getframe(h1); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SIMULATION %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for trial=1:nTrial    
      
      fCa = zeros(Ne,tmax);  %instantaneous fast Ca sensor, integrates the firing rate of E
      fCaInh = zeros(Ni,tmax);  %instantaneous fast Ca sensor, integrates the firing rate of I
      
      hR = zeros(tmax,Ne+Ni); %history of Inh and Ex rate 
      
     E = zeros(Ne,1);
     I = zeros(Ni,1);
     a = zeros(Ne,1);
      
           
      evoked = zeros(1,tmax);
      evoked(EvokedOn:EvokedOn+EvokedDur)=EvokedAmp;
      
%%
      for t=1:tmax        
         
         OUE = OUE + OUtau*(OUmu-OUE) + OUsigma*randn(Ne,1); %Ornstein-Uhlenbeck Noise for excitatory unit
         OUI = OUI + OUtau*(OUmu-OUI) + OUsigma*randn(Ni,1); %Ornstein-Uhlenbeck Noise for inhibitory unit
         
         E = E + (-E + F(WEE*E - WEI*I - a + evoked(t) + OUE,gainE,thetaE) )/Etau;
         I = I + (-I + F(WIE*E - WII*I + OUI,gainI,thetaI) )/Itau;
         
         a = a + (-a + Beta*E)/tauA; %ADAPTATION 
         
         Emaxvec = E>E_MAX; E(Emaxvec) = E_MAX; %Neurons have a saturation of their rates
         Imaxvec = I>I_MAX; I(Imaxvec) = I_MAX;

         
         hR(t,:) = [E' I'];
         
         % Ex Ca Sensors
         fCa(:,t) = E;
         fCaInh(:,t) = I;
         
         
      end
      

         ExAvg    = ExAvg  + (-ExAvg  + mean(fCa(:,end-0.5/dt:end),2))/tau_trial; %we average at the end of the trial to avoid evoked
         InhAvg   = InhAvg + (-InhAvg + mean(fCaInh(:,end-0.5/dt:end),2))/tau_trial;
         
      
    %%  
    
      WEEp = sum(WEE,2); %update sum of presynaptic weights for plot
      WEIp = sum(WEI,2);
      WIEp = sum(WIE,2);
      WIIp = sum(WII,2);
     
      trialhistFCa(trial,:) = ExAvg;
      trialhistFCaInh(trial,:) = InhAvg;
      trialhistWEE(trial,:) = WEE(:,end);      
      trialhistWEI(trial,:) = WEI(:,end);     
      trialhistWIE(trial,:) = WIE(:,end);   
      trialhistWII(trial,:) = WII(:,end);            
      trialhistWEEp(trial,:) = WEEp;
      trialhistWEIp(trial,:) = WEIp;
      trialhistWIEp(trial,:) = WIEp;
      trialhistWIIp(trial,:) = WIIp;
      
      x=WEEp;
      y1=WEIp;
      [R,p] = corr(x,y1,'rows','complete');
      P = polyfit(x,y1,1);
      yfit = P(1)*x+P(2);ix=WIEp;
      iy1=WIIp;
      [iR,ip] = corr(ix,iy1,'rows','complete');
      iP = polyfit(ix,iy1,1);
      iyfit = iP(1)*ix+iP(2);
      
      
      if HOMEOSTATIC_FLAG 
          
  

            EAvg =  max(1,ExAvg); %Average activity is rectified,for trials that start with 0 rate (development settings), otherwise weights would never move
            IAvg = max(1,InhAvg);
                       
            
            newWEE = WEE + alpha*EAvg'*(sum(InhSet-IAvg)/Ni) + alpha*(ExSet-EAvg)*EAvg';
            newWEE = newWEE - diag(diag(newWEE));
            
            newWEI = WEI - alpha*IAvg'*(sum(InhSet-IAvg)/Ni) - alpha*(ExSet-EAvg)*IAvg';

            newWIE = WIE - alpha*EAvg'*(sum(ExSet-EAvg)/Ne) + alpha*(InhSet-IAvg)*EAvg'; 
         
            newWII = WII + alpha*IAvg'*(sum(ExSet-EAvg)/Ne) - alpha*(InhSet-IAvg)*IAvg'; 
            newWII = newWII - diag(diag(newWII));
                   
         
        WEE = newWEE; WEI = newWEI; WIE = newWIE; WII = newWII;
         
         %If weights fall below a minimum or are NaN set to minimum
         
         WEE(WEE<WEE_MIN/(Ne-1))=WEE_MIN/(Ne-1);
         WEE(isnan(WEE))=WEE_MIN/(Ne-1);
         WEI(WEI<WEI_MIN/Ni)=WEI_MIN/Ni;
         WEI(isnan(WEI))=WEI_MIN/Ni;
         WIE(WIE<WIE_MIN/Ne)=WIE_MIN/Ne;
         WIE(isnan(WIE))=WIE_MIN/Ne;
         WII(WII<WII_MIN/(Ni-1))=WII_MIN/(Ni-1);
         WII(isnan(WII))=WII_MIN/(Ni-1);
         WEE = WEE - diag(diag(WEE));
         WII = WII - diag(diag(WII));
            

      end
     %%
          
      
      if GRAPHICS %&& rem(trial,10)==0
      refreshdata(h1) 
      drawnow   
      
          if ismember(trial,savetrials)
              %saveas(gcf,['trial',num2str(trial)],'jpg')
              %saveas(gcf,['trial',num2str(trial)],'svg')

          end
      
      end
      
      if VIDEO
      counter = counter+1;
      frames(counter) = getframe(h1); 
      end
      
      
 end
   
 Wend = [WEE,WEI;WIE,WII];  
 %save(['METApopmodel_',learning_rule,'Ex',num2str(ExSet),'Inh',num2str(InhSet),'.mat'])
 
   if VIDEO
    video = VideoWriter([learning_rule,'_MultiUnit_demo']);
    video.FrameRate = 2;
    open(video)
    writeVideo(video,frames);
    close(video)
    clear video
    clear frames
   end
   
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% final PLOTTING %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if GRAPHICS   

    figure('Position', [10 10 1300 500]);     
     subplot(1,2,1)     
     imagesc(Winit)
%      cMap = getPyPlot_cMap('coolwarm',128);
%      colormap(cMap);
     colorbar
     xlabel('pre')
     ylabel('post')
     title('pre training')    
    subplot(1,2,2)
    imagesc(Wend)
    colorbar
    xlabel('pre')
    ylabel('post')
    title('post training')
%     saveas(gcf,'Winitend','jpg')
%     saveas(gcf,'Winitend','svg')
    

    %%
    figure
    subplot(2,2,1)
    histogram(Winit(1:Ne,1:Ne))
    hold on
    histogram(WEE)
    xlabel('WEE')
    subplot(2,2,2)
    histogram(Winit(1:Ne,Ne+1:end))
    hold on
    histogram(WEI)
    legend('init','end')
    xlabel('WEI')
    subplot(2,2,3)
    histogram(Winit(Ne+1:end,1:Ne))
    hold on
    histogram(WIE)
    xlabel('WIE')
    subplot(2,2,4)
    histogram(Winit(Ne+1:end,Ne+1:end))
    hold on
    histogram(WII)
    xlabel('WII')
    %saveas(gcf,'Winitendhistogram','jpg')

    %%
     figure('Position', [10 10 1200 500]);     
     sgtitle('Total currents')
     subplot(1,2,1)
     plot(WEE*E,WEI*I,'o','color',[0 0.5 0])
     xlabel('WEE*E')
     ylabel('WEI*I')
     set(gca,'FontSize',20)
    set(findobj(gca,'type','line'),'linew',3)
    set(gca,'linew',4)
    set(gca, 'box', 'off')
    hold on
    x=WEE*E;
    y1=WEI*I;
    [R,p] = corr(x,y1,'rows','complete');
    P = polyfit(x,y1,1);
    yfit = P(1)*x+P(2);
    plot(x,yfit,'b','LineWidth',2);
    title(['R = ',num2str(R),'p = ',num2str(p)],'FontSize',15)

    subplot(1,2,2)
     plot(WIE*E,WII*I,'o','color',[1 0 0])
     xlabel('WIE*E')
     ylabel('WII*I')
     set(gca,'FontSize',20)
    set(findobj(gca,'type','line'),'linew',3)
    set(gca,'linew',4)
    set(gca, 'box', 'off')
    hold on
    x=WIE*E;
    y1=WII*I;
    [R,p] = corr(x,y1,'rows','complete');
    P = polyfit(x,y1,1);
    yfit = P(1)*x+P(2);
    plot(x,yfit,'b','LineWidth',2);
    title(['R = ',num2str(R),'p = ',num2str(p)],'FontSize',15)
    %saveas(gcf,'currents','jpg')
    
    %%
    figure('Position', [10 10 1200 500]);     
     sgtitle('W end')
     subplot(1,2,1)
     scatter(WEEp,WEIp,[60],'filled','MarkerFaceColor',[0 0.5 0],'MarkerFaceAlpha',0.6)
     %plot(WEEp,WEIp,'o','color',[0 0.5 0])
     xlabel('WEE')
     ylabel('WEI')
     set(gca,'FontSize',20)
    set(findobj(gca,'type','line'),'linew',3)
    set(gca,'linew',4)
    set(gca, 'box', 'off')
    hold on
    
    x=WEEp;
    y1=WEIp;
    [R,p] = corr(x,y1,'rows','complete');
    P = polyfit(x,y1,1);
    yfit = P(1)*x+P(2);
    plot(x,yfit,'b','LineWidth',2,'color',[0, 0.4470, 0.7410]);
    title(['R = ',num2str(R),'p = ',num2str(p)],'FontSize',15)

% newWEE=6:8;
% newWEI = (ExSet/InhSet) * newWEE - ExSet/(InhSet*gainE) - thetaE/InhSet;
% plot(newWEE,newWEI,'b','linewidth',1,'color',[0, 0.4470, 0.7410])

    subplot(1,2,2)
    scatter(WIEp,WIIp,[60],'filled','MarkerFaceColor',[1 0 0],'MarkerFaceAlpha',0.6)
     %plot(WIEp,WIIp,'o','color',[1 0 0])
     xlabel('WIE')
     ylabel('WII')
     set(gca,'FontSize',20)
    set(findobj(gca,'type','line'),'linew',3)
    set(gca,'linew',4)
    set(gca, 'box', 'off')
    hold on
    
    x=WIEp;
    y1=WIIp;
    [R,p] = corr(x,y1,'rows','complete');
    P = polyfit(x,y1,1);
    yfit = P(1)*x+P(2);
    plot(x,yfit,'b','LineWidth',2,'color',[0, 0.4470, 0.7410]);
    title(['R = ',num2str(R),'p = ',num2str(p)],'FontSize',15)

% newWIE=7.5:9.5;
% newWII = (newWIE*ExSet - thetaI)/InhSet - 1/gainI; 
% plot(newWIE,newWII,'b','linewidth',1,'color',[0, 0.4470, 0.7410])

%     saveas(gcf,'preW','jpg')
%     saveas(gcf,'preW','svg')

    %%
     %%
    figure('Position', [10 10 1200 500]);     
      sgtitle('W init')
     subplot(1,2,1)
     scatter(initWEEp,initWEIp,[60],'filled','MarkerFaceColor',[0 0.5 0],'MarkerFaceAlpha',0.6)
     %plot(initWEEp,initWEIp,'o','color',[0 0.5 0])
     xlabel('WEE')
     ylabel('WEI')
     set(gca,'FontSize',20)
    set(findobj(gca,'type','line'),'linew',3)
    set(gca,'linew',4)
    set(gca, 'box', 'off')
    hold on
    x=initWEEp;
    y1=initWEIp;
    [R,p] = corr(x,y1,'rows','complete');
    P = polyfit(x,y1,1);
    yfit = P(1)*x+P(2);
    plot(x,yfit,'b','LineWidth',2,'color',[0, 0.4470, 0.7410]);
    title(['R = ',num2str(R),'p = ',num2str(p)],'FontSize',15)

    subplot(1,2,2)
     scatter(initWIEp,initWIIp,[60],'filled','MarkerFaceColor',[1 0 0],'MarkerFaceAlpha',0.6)
     %plot(initWIEp,initWIIp,'o','color',[1 0 0])
     xlabel('WIE')
     ylabel('WII')
     set(gca,'FontSize',20)
     xlim([5.6 8.1])
    set(findobj(gca,'type','line'),'linew',3)
    set(gca,'linew',4)
    set(gca, 'box', 'off')
    hold on
    x=initWIEp;
    y1=initWIIp;
    [R,p] = corr(x,y1,'rows','complete');
    P = polyfit(x,y1,1);
    yfit = P(1)*x+P(2);
    plot(x,yfit,'b','LineWidth',2,'color',[0, 0.4470, 0.7410]);
    title(['R = ',num2str(R),'p = ',num2str(p)],'FontSize',15)
%     saveas(gcf,'preWinit','jpg')
%     saveas(gcf,'preWinit','svg')

    %%
    
      WEEpo = sum(WEE,1); %update sum of presynaptic weights for plot
      WEIpo = sum(WEI,1);
      WIEpo = sum(WIE,1);
      WIIpo = sum(WII,1);
      
    figure('Position', [10 10 1200 500]);     
     sgtitle('Corr input-output weights')
     subplot(1,2,1)
     plot(WEEp,WEEpo,'o','color',[0 0.5 0])
     xlabel('WEEp')
     ylabel('WEEpo')
     set(gca,'FontSize',20)
    set(findobj(gca,'type','line'),'linew',3)
    set(gca,'linew',4)
    set(gca, 'box', 'off')
    hold on
    x=WEEp;
    y1=WEEpo';
    [R,p] = corr(x,y1,'rows','complete');
    P = polyfit(x,y1,1);
    yfit = P(1)*x+P(2);
    plot(x,yfit,'b','LineWidth',2);
    title(['R = ',num2str(R),'p = ',num2str(p)],'FontSize',15)

    subplot(1,2,2)
     plot(WIEp,WEIpo,'o','color',[1 0 0])
     xlabel('WIEp')
     ylabel('WEIpo')
     set(gca,'FontSize',20)
    set(findobj(gca,'type','line'),'linew',3)
    set(gca,'linew',4)
    set(gca, 'box', 'off')
    hold on
    x=WIEp;
    y1=WEIpo';
    [R,p] = corr(x,y1,'rows','complete');
    P = polyfit(x,y1,1);
    yfit = P(1)*x+P(2);
    plot(x,yfit,'b','LineWidth',2);
    title(['R = ',num2str(R),'p = ',num2str(p)],'FontSize',15)
    %saveas(gcf,'outputW','jpg')


end

 