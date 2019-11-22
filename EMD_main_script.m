% -------------------------------------------------------------------------
% This script employs the EMD method to achieve the power spectral
% concentration of the last intrinsic mode functions
%
% Author: Luiz Giovanini
% Created on Jan 30, 2018
% -------------------------------------------------------------------------

clear; clc; close all;

% sampling frequency of data
Fs = 63;

% vectors with the names of the individuals and type of game
nomes = {'ana','carlos','debora','edgard','lourenco'};
tipojogo = {'cabeceio','esqui','goleiro'};

% vector with the columns names in the output file
nome_colunas = {'Sujeito','Jogo','Trial','Nº IMF','Última IMF','Penúltima IMF','...'};

% first line to write into the output file
linha = 1;

% there are 5 individuals
for sujeito = 1:5
   
    % there are 5 games for each individual
    for n_jogo = 1:3
       
	% there are 9 trials of each individual for each game
        for trial = 1:9                      
            
            % read the file
	    nome_arquivo = strcat(char(nomes(sujeito)),'_',char(tipojogo(n_jogo)),'_0',num2str(trial),'.xls');
            dados = xlsread(nome_arquivo);
            y = detrend(dados(:,3));       
            
            % applying EMD (Empirical Mode Decomposition)
            IMF = emd(y);
            
            % take the number of IMFs computed from the signal
            [n_IMF,~] = size(IMF);
            
            % compute the power spectral density
            pot_total = 0;
            for i = 1:n_IMF

                % compute 99% of the power spectral of each IMF
                [p,f] = pwelch(IMF(i,:),[],[],[],Fs,'onesided');
                Pacumulada = cumsum(p,1)/sum(p);
                F99 = find(Pacumulada>=0.99);                
                if isempty(F99), fp(i) = -1;  % tratativa de erro 
                else fp(i) = f(F99(1));             
                end                

                pp(i) = sum(p); % pot. total da IMF corrente
                pot_total = pot_total + pp(i);  % acumula para calcular a potência de todas as IMFs juntas  
            end          
            
            pp = pp/pot_total;   % calcula o percentual de potência que cada IMF representa perante a potência total

            % update the output matrix
            RES(linha,1) = sujeito;
            RES(linha,2) = n_jogo;
            RES(linha,3) = trial;
            RES(linha,4) = n_IMF;
            RES(linha,5:5+length(fp)-1) = flip(fp);
            
            POT(linha,1) = sujeito;
            POT(linha,2) = n_jogo;
            POT(linha,3) = trial;
            POT(linha,4) = n_IMF;
            POT(linha,5:5+length(pp)-1) = flip(pp);
                        
            linha = linha+1;
            
            fprintf('>> Sujeito:%d, Jogo: %d, Trial: %d. [Processamento %f%% concluído...]\n', sujeito, n_jogo, trial, ((linha-1)/135)*100)
            

            clear nome_arquivo; clear dados; clear y; clear IMF; clear p; clear f; clear fp; clear pp;
        end

        xlswrite('resultado_emd_FREQ.xlsx',nome_colunas,1,'A1');
        xlswrite('resultado_emd_FREQ.xlsx',RES,1,'A2');
        
        xlswrite('resultado_emd_POT.xlsx',nome_colunas,1,'A1');
        xlswrite('resultado_emd_POT.xlsx',POT,1,'A2');        
    end
end


