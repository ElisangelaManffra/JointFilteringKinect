% This script performs the Residual Analysis procedure proposed by Winter (1990)

clear all
close all
clc

% disp('abrindo arquivo...')
% [filename,dname]=uigetfile('*.*','selecione o arquivo desejado');
% cd(dname)
% oldFolder = cd(dname);
% disp('')
% if filename==0
%     disp('finalizado')
%     return
% end


arquivo = 'Type the path';
x= xlsread ('Type the filename');


prompt = {'Type the frequency (in Hz) used to record the signal:'};
dlg_title = '';
num_lines = 1;
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer1 = inputdlg(prompt,dlg_title,num_lines);

fs=str2num(answer1{1});

prompt = {'Type the number of the column to be analyzed (vector)'};
dlg_title = '';
num_lines = 1;
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer2 = inputdlg(prompt,dlg_title,num_lines);

N_col=str2num(answer2{1});

prompt = {'Type the order of the filter to be tested (n)'};
dlg_title = '';
num_lines = 1;
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer3 = inputdlg(prompt,dlg_title,num_lines);

order=str2num(answer3{1});

prompt = {'Type the number of frequency values for the analysis:'};
dlg_title = '';
num_lines = 1;
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer4 = inputdlg(prompt,dlg_title,num_lines);

n_fcortes=str2num(answer4{1});

f_cortes=[1:n_fcortes]';

razaoT=1/fs;

signal=x(:,N_col);
T=[1:length(signal)]*razaoT;

for i=1:length(T)
    Tempo_total=T(i);
end

N_pontos=Tempo_total*fs;

const=1/N_pontos;

for i=1:length(f_cortes)
    n=order;
    Wn=f_cortes(i)/(fs/2);
    [d,c] = butter(n,Wn,'low');
    signal_filter(i,:) = filtfilt(d,c,signal);
end

signal_filter=signal_filter';

for i=1:length(f_cortes)
    residuo(i)=sqrt((sum((signal-signal_filter(:,i)).^2))*const);
end
    
residuo=residuo';

f_cortes_0=[0;f_cortes];
residuo_0=[0;residuo];

scrsz = get(0,'ScreenSize');
figure('Position',scrsz)
plot(f_cortes,residuo)
[clique]=ginput(1);
clique=round(clique(1));
indice=find(f_cortes==clique);
close all

reg_f_cortes=[f_cortes(indice);f_cortes((length(f_cortes)-1))];
reg_residuo=[residuo(indice);residuo((length(residuo)-1))];

[R,Slope,Intersect]=regression(reg_f_cortes,reg_residuo,'one');

tmp = abs(residuo-Intersect);
[idx idy] = min(tmp);
f_ideal=f_cortes(idy);

reta_reg=linspace(Intersect,residuo((length(residuo)-1)),length(residuo)-1)';
reta_par_zero=linspace(Intersect,Intersect,length(residuo_0))';

scrsz = get(0,'ScreenSize');
figure('Position',scrsz)
plot(f_cortes,residuo,'k')
title(['Optimal cutoff frequency = ',num2str(f_ideal)])
hold on
plot(f_cortes_0(1:(length(f_cortes)-1)),reta_reg,'r:')
plot(f_cortes_0,reta_par_zero,'g:')
plot([f_ideal;f_ideal],[0;max(residuo)],'b:')
plot(0,Intersect,'o','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',7)
plot(f_ideal,Intersect,'o','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',7)
plot(f_ideal,0,'o','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',7)
% set(gca,'XTick',0:f_cortes(1):f_cortes(length(f_cortes)))
%text(f_ideal,residuo((length(residuo)-2)),['Frequência de corte ideal =
%',num2str(f_ideal)],'HorizontalAlignment','left')
hold off

clear all