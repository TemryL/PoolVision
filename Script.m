%*******************************************************
%Name of file ......... : Analyse.m

%Authors...... : MERY Tom, LELIEVRE Maxime
%Version...... : 05/06/2020
 
%********************************************************

%% Origin inversion and Top-Left coordinate to center of balls coordinate :
X_Red=X_Red+5;
X_Yellow=X_Yellow+5;
X_White=X_White+5;
Y_Red=H-Y_Red-5;
Y_Yellow=H-Y_Yellow-5;
Y_White=H-Y_White-5;

%% Define X, Y and player :
%More details about this part are available on PDF documentation
X=[X_Red;X_Yellow;X_White];
Y=[Y_Red;Y_Yellow;Y_White];
player={'Red','Yellow','White'};

%% Detection of Billard Box :
Xmin=min([X_Red X_Yellow X_White]);
Ymin=min([Y_Red Y_Yellow Y_White]);
Xmax=max([X_Red X_Yellow X_White]);
Ymax=max([Y_Red Y_Yellow Y_White]);

%% Create displacement vector :
%More details about this part are available on PDF documentation
D=[-(diff(X_Red)+1i*diff(Y_Red));...
    -(diff(X_Yellow)+1i*diff(Y_Yellow));...
    -(diff(X_White)+1i*diff(Y_White))];

%% Find and Replace outliers :
%More details about this part are available on PDF documentation
Oi_R=find(isoutlier(sqrt(X_Red.^2+Y_Red.^2),'movmedian',5));
Oi_Y=find(isoutlier(sqrt(X_Yellow.^2+Y_Yellow.^2),'movmedian',5));
Oi_W=find(isoutlier(sqrt(X_White.^2+Y_White.^2),'movmedian',5));

Oi_R=intersect(Oi_R,find(abs(D(1,:))>200));
Oi_Y=intersect(Oi_Y,find(abs(D(2,:))>200));
Oi_W=intersect(Oi_W,find(abs(D(3,:))>200));

X_Red(Oi_R)=(X_Red(Oi_R-1)+X_Red(Oi_R+1))/2;
Y_Red(Oi_R)=(Y_Red(Oi_R-1)+Y_Red(Oi_R+1))/2;
X_Yellow(Oi_Y)=(X_Yellow(Oi_Y-1)+X_Yellow(Oi_Y+1))/2;
Y_Yellow(Oi_Y)=(Y_Yellow(Oi_Y-1)+Y_Yellow(Oi_Y+1))/2;
X_White(Oi_W)=(X_White(Oi_W-1)+X_White(Oi_W+1))/2;
Y_White(Oi_W)=(Y_White(Oi_W-1)+Y_White(Oi_W+1))/2;

D=[-(diff(X_Red)+1i*diff(Y_Red));...
    -(diff(X_Yellow)+1i*diff(Y_Yellow));...
    -(diff(X_White)+1i*diff(Y_White))];

%% Distance :
dist_r=round(sum(abs(D(1,:))));
dist_y=round(sum(abs(D(2,:))));
dist_w=round(sum(abs(D(3,:))));

%% Define the order of movement of the balls :
%More details about this part are available on PDF documentation
dmin=sqrt(2);
i_Red=find(abs(D(1,:))>dmin,1); 
i_Yellow=find(abs(D(2,:))>dmin,1);
i_White=find(abs(D(3,:))>dmin,1);

idx=sort([i_Red i_Yellow i_White]);
idx1=idx(1); idx2=idx(2);
if length(idx)==2
    idx3=[];
else
    idx3=idx(3);
end
i_Red(isempty(i_Red))=0; 
i_Yellow(isempty(i_Yellow))=0; 
i_White(isempty(i_White))=0;

b1=find([idx1==i_Red idx1==i_Yellow idx1==i_White]);
b2=find([idx2==i_Red idx2==i_Yellow idx2==i_White]);
b3=find([idx3==i_Red idx3==i_Yellow idx3==i_White]);
X_1=X(b1,:); Y_1=Y(b1,:);

%% BandTouch :
%More details about this part are available on PDF documentation
BdT=(sign(real([D(:,1) D]))~=sign(real([D D(:,end)])))...
    |(sign(imag([D(:,1) D]))~=sign(imag([D D(:,end)])));
BdT=BdT&((Xmax-10<=X(b1,:))|(Ymax-10<=Y(b1,:))|(Xmin+10>=X(b1,:))|(Ymin+10>=Y(b1,:)))...
    &(abs(angle([D(:,1) D])-angle([D D(:,end)]))>=0.5);
BdT(:,1:idx2)=0;
BdT(:,idx3:end)=0;

%% Result :
Bandtouched=sum(BdT(b1,idx2:idx3));
Balltouched=length([idx2 idx3]);
if Balltouched==2 && Bandtouched>=3
    Result='Win';
else
    Result='Lose';
end

%% Create score sheet :
figure(1);
hold on;
rectangle('Position',[Xmin Ymin Xmax-Xmin Ymax-Ymin],'EdgeColor','b')
axis([Xmin Xmax 0 Ymax]);
text(200,Ymin-20,['Score sheet for "',char(player(b1)),'"']);
text(200,Ymin-40,['---',Result,'---']);
text(200,20,['dist(r):',num2str(dist_r),'px']);
text(375,20,['dist(y):',num2str(dist_y),'px']);
text(550,20,['dist(w):',num2str(dist_w),'px']);
text(550,Ymin-20,[num2str(Balltouched),' ball(s) touched']);
text(550,Ymin-40,[num2str(Bandtouched),' band(s) touched']);
if Bandtouched
        plot(X_1(BdT(b1,:)), Y_1(BdT(b1,:)), '.','Color',Band_Touch,'MarkerSize',25);
end
plot(X_White,Y_White,Line,'Color','#7E2F8E');
plot(X_Red,Y_Red,Line,'Color','#A2142F');
plot(X_Yellow,Y_Yellow,Line,'Color','#EDB120');
title(['Scores sheet - F',Sequence,' - ( ',datestr(now),' )']);
plot(X(b2,idx2), Y(b2,idx2),'o','Color',Ball_Touch,'MarkerSize',10);
plot(X(b3,idx3), Y(b3,idx3),'o','Color',Ball_Touch,'MarkerSize',10);
saveas(gcf,['ScoreSheet_F',Sequence,'.pdf'],'pdf');



