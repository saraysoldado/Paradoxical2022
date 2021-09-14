
%called by multi_unit_Up_Dev
%ssaray@ucla.edu
%dbuono@ucla.edu

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Firing rate over time figure (2 E and 2 I example), with 2 example weights. Pulled firing rate of all neurons. 
if(1)
     h1=figure('Renderer', 'painters', 'Position', [10 10 1200 1000]);
     set(gcf,'color','w');
     hold on
        subplot(5,2,1)
        plot(dt-EvokedOn*dt:dt:tmax*dt-EvokedOn*dt,hR(:,18),'color',[0 0.5 0],'linewidth',2,'ydatasource','hR(:,18)'); 
        line([dt-EvokedOn*dt tmax*dt-EvokedOn*dt],[ExSet ExSet],'color',[0 0.5 0],'linestyle',':','linewidth',2);
        ylim([0 20])
        %xlim([dt-EvokedOn*dt tmax*dt-EvokedOn*dt])
        xlim([dt-EvokedOn*dt 0.7])
        ylabel('E (Hz)','FontSize',16)
        set(gca,'FontSize',12)


        subplot(5,2,3)
        plot(dt-EvokedOn*dt:dt:tmax*dt-EvokedOn*dt,hR(:,40),'color',[0 0.5 0],'linewidth',2,'ydatasource','hR(:,40)');   
        line([dt-EvokedOn*dt tmax*dt-EvokedOn*dt],[ExSet ExSet],'color',[0 0.5 0],'linestyle',':','linewidth',2);
        ylim([0 20])
        xlim([dt-EvokedOn*dt 0.7])
        set(gca,'FontSize',12)

        
        subplot(5,2,5)
        plot(dt-EvokedOn*dt:dt:tmax*dt-EvokedOn*dt,hR(:,Ne+1),'color',[1 0 0],'linewidth',2,'ydatasource','hR(:,Ne+1)');  
        line([dt-EvokedOn*dt tmax*dt-EvokedOn*dt],[InhSet InhSet],'color',[1 0 0],'linestyle',':','linewidth',2);
        ylim([0 55])
        xlim([dt-EvokedOn*dt 0.7])
        ylabel('I (Hz)','FontSize',16)
        set(gca,'FontSize',12)


        subplot(5,2,7)
        plot(dt-EvokedOn*dt:dt:tmax*dt-EvokedOn*dt,hR(:,Ne+12),'color',[1 0 0],'linewidth',2,'ydatasource','hR(:,Ne+12)');
        line([dt-EvokedOn*dt tmax*dt-EvokedOn*dt],[InhSet InhSet],'color',[1 0 0],'linestyle',':','linewidth',2);
        xlabel('Time (sec)','Fontsize',16)
        ylim([0 55])
        xlim([dt-EvokedOn*dt 0.7])
        set(gca,'FontSize',12)

        
        subplot(5,2,[9 10])
        %subplot(5,2,9)
        plot(NaN(nTrial,20),'color',[77/255 166/255 77/255 0.25],'ydatasource','trialhistFCa(:,1:20)','linewidth',1);%[0 0.5 0]
        hold on
        plot(NaN(nTrial,1),'color',[77/255 166/255 77/255],'ydatasource','nanmean(trialhistFCa,2)','linewidth',4);%[0 0.5 0]
        plot(NaN(nTrial,Ni),'color',[255/255,112/255,112/255 0.25],'ydatasource','trialhistFCaInh','linewidth',1); %[255/255,51/255,51/255]
        plot(NaN(nTrial,1),'color',[255/255,112/255,112/255],'ydatasource','nanmean(trialhistFCaInh,2)','linewidth',4);%[0 0.5 0]
        line([1 nTrial],[ExSet ExSet],'color',[0 0.5 0],'linestyle','--','linewidth',2);
        line([1 nTrial],[InhSet InhSet],'color',[255/255,51/255,51/255],'linestyle','--','linewidth',2);
        %ylim([0 max(ExSet,InhSet)*3])
        ylabel('Mean E/I (Hz)','Fontsize',16)
        xlabel('Trials','Fontsize',16)
        ylim([0 35]) %25
        set(gca,'FontSize',14)

        
        
        subplot(5,2,[2 4])
     plot(trialhistWEEp,trialhistWEIp,'-o','MarkerSize',3,'LineWidth',0.5,'color',[196/255,193/255,193/255],'xdatasource','trialhistWEEp','ydatasource','trialhistWEIp');
     hold on
     plot(WEEp,WEIp,'o','LineWidth',2,'color',[0 0.5 0],'xdatasource','WEEp','ydatasource','WEIp');
%      xlim([4.8 5.2])
%      ylim([1 1.15])
     xlabel('WEE')
     ylabel('WEI')
     set(gca,'FontSize',12)
     %set(findobj(gca,'type','line'),'linew',3)
     %set(gca,'linew',4)
     %set(gca, 'box', 'off')
     hold on
     x=WEEp;
     y1=WEIp;
    [R,p] = corr(x,y1,'rows','complete');
     P = polyfit(x,y1,1);
     yfit = P(1)*x+P(2);
     plot(x,yfit,'b','LineWidth',2,'xdatasource','x','ydatasource','yfit');
     %title(['R = ',num2str(R),'p = ',num2str(p)],'FontSize',15)
     %str = ['R = ',num2str(R),'p = ',num2str(p)];
     %hTitle1 = title(str,'FontSize',15);
     
    
     
        subplot(5,2,[6 8])
     plot(trialhistWIEp,trialhistWIIp,'-o','MarkerSize',3,'LineWidth',0.5,'color',[196/255,193/255,193/255],'xdatasource','trialhistWIEp','ydatasource','trialhistWIIp');
     hold on
     plot(WIEp,WIIp,'o','color',[1 0 0],'LineWidth',2,'xdatasource','WIEp','ydatasource','WIIp');
%      xlim([9.8 10.2])
%      ylim([1.4 1.6])
     xlabel('WIE')
     ylabel('WII')
     set(gca,'FontSize',12)
     %set(findobj(gca,'type','line'),'linew',3)
     %set(gca,'linew',4)
     %set(gca, 'box', 'off')
     hold on
     ix=WIEp;
     iy1=WIIp;
     [iR,ip] = corr(ix,iy1,'rows','complete');
     iP = polyfit(ix,iy1,1);
     iyfit = iP(1)*ix+iP(2);
     plot(ix,iyfit,'b','LineWidth',2,'xdatasource','ix','ydatasource','iyfit');
     %title(['R = ',num2str(iR),'p = ',num2str(ip)],'FontSize',15)
     %str = ['R = ',num2str(iR),'p = ',num2str(ip)];
     % = title(str,'FontSize',15);
end

    
%% MEAN RATE OVER TIME ON IMAGESC  

if(0)
    figure
    rImage = imagesc([trialhistFCa';trialhistFCaInh']);
    colorbar
    caxis([0 2*InhSet])
    xlabel('trials')
    ylabel('units')
    title('rate over trials')
end

