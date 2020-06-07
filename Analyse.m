clc; clear; close all

X_Red=[656 656 656 656 656 656 656 656 656 656 656 656 656 656 646 624 605 589 572 557 540 524 508 492 476 461 445 429 413 398 383 368 353 341 330 319 308 297 286 275 265 254 244 233 223 213 202 192 183 173 163 153 143 134 132 138 143 149 154 159 164 169 174 178 183 188 193 198 202 206 210 215 219 223 228 231 235 239 243 246 250 253 257 260 263 267 270 273 276 278 281 284 287 289 291 294 297 299 301 303 305 308 309 311 312 315 316 318 319 320 322 322 324 325 326 326 327 329 329 329 330 330 330 331 331 331 332 332 332 332 332 333];
Y_Red=[152 152 152 152 152 152 152 152 152 152 152 152 152 152 161 177 192 205 219 231 244 257 270 283 295 308 320 333 344 357 369 381 389 381 375 369 363 357 352 346 340 334 329 323 317 313 307 301 296 291 285 280 275 270 266 261 256 252 247 243 239 235 231 227 223 219 215 211 208 205 201 197 194 190 187 184 181 178 174 171 169 166 163 160 157 155 152 149 147 145 143 141 138 136 134 133 130 128 127 125 123 121 120 119 117 116 115 113 112 111 110 109 108 107 106 106 105 104 104 103 103 102 101 101 101 101 101 100 100 100 100 100];
X_Yellow=[667 667 667 667 667 667 667 667 667 667 667 667 667 667 677 698 716 732 725 716 708 698 682 665 650 634 620 604 590 576 561 546 532 518 504 490 476 468 460 452 444 436 427 419 412 404 396 388 380 374 366 358 351 344 336 329 322 316 308 302 294 288 282 274 268 262 255 248 242 236 230 224 218 212 206 200 194 188 184 179 175 171 167 163 160 156 152 148 144 141 138 134 132 128 129 131 133 134 136 138 139 140 142 144 144 146 146 148 148 149 150 150 151 152 152 152 152 153 153 154 154 154 154 154 154 154 154 154 154 154 154 154];
Y_Yellow=[100 100 100 100 100 100 100 100 100 100 100 100 100 114 160 193 227 261 295 332 368 386 359 333 312 293 275 256 239 221 203 185 168 150 133 116 100 108 118 127 135 143 151 159 167 175 183 191 198 206 214 221 229 236 243 250 258 265 272 278 285 292 299 305 312 318 325 331 338 344 350 356 362 368 374 379 385 390 387 384 381 378 376 373 370 367 365 362 360 358 355 353 350 348 346 345 342 341 339 337 336 334 332 331 330 328 327 326 325 323 322 321 320 320 319 318 317 317 317 316 316 315 315 315 315 315 315 315 315 315 315 315];
X_White=[131 131 130 130 130 130 130 130 130 130 130 130 130 130 130 130 131 131 131 131 131 131 131 131 131 131 131 131 131 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 131 131 131 131 131 131 131 131 131 131 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 131 131 131 131 131 131 131 131 131 131 131 130 130 130 130 130 130 130 130 130 130 130 130 131 130 131 131 131 131 131 131 131 131 130 131 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130 130];
Y_White=[321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321 321];
H=480;
Line='.-';
Sequence='1';
Ball_Touch=[0	1	1];
Band_Touch=[0	1	0];

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



