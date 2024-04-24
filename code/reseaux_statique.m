close all
clear all

%% Projet Réseaux de télécommunications

n = 10;    % Nombre de téléphones par station 
T = 10*60; % Dernier établissement de communication possible (s)
d = 5*60;  % Durée maximale d'un appel (s) = 5 minutes

% Capacité des liens
CA1_CA2 = 10;
CA2_CA3 = 10;

CA1_CTS1 = 100;
CA1_CTS2 = 100;
CA2_CTS1 = 100;
CA2_CTS2 = 100;
CA3_CTS1 = 100;
CA3_CTS2 = 100;

CTS1_CTS2 = 1000;


% Initialisation variables de visualisation/ résultat
crash_comm = [];

echec_appel = 0;  %nb appels impossible
reussi_appel = 0; %nb appels reussi

% Initialisation parametres d'appels
p_appel = 0.2; % Probabilité d'un appel
memoire = zeros(130,3); % Appels en cours 

t = 1; % Indice de temps (s)

while (t < T) % STOP à la fin de notre durée d'expèrience
%while sum(crash_comm) == 0 % STOP quand il y a une communication qui
%est rejetée

    appels = rand(1,3) < p_appel; % Déclenche un appel avec une proba de p_appel
    

    % Appels entre CA1 et CA2
    % Trajet : CA1 <--> CA2
    if appels(1)
        if ~CA1_CA2       % Capacité du lien == 0 ne peut accepter d'autre appel dans ce lien
            % Communication refusée
            % Donc echec de l'appel
            echec_appel =+ 1;
            crash_comm = [3 4];
        else
           % Appel Réussi 
           reussi_appel =+ 1;
           CA1_CA2 = CA1_CA2 - 1;     % On diminue la capacité du lien car appel utilise la ressource du lien
           z = find(memoire(:,1)==0); % permet de remplir des zeros qui vont réapparaitre
           memoire(z(1),1) = randi(d);% Appel entre 1 & 5 minutes (proba uniforme)
        end
    end

    % Appels entre CA2 et CA3
    % Trajet CA2 <--> CA3
    if appels(2)
        if ~CA2_CA3
            echec_appel =+ 1;
            crash_comm = [4 5];
        else
           reussi_appel =+ 1;
           CA2_CA3 = CA2_CA3 - 1; % CA2 <-> CA3
           z = find(memoire(:,2)==0);
           memoire(z(1),2) = randi(d);
        end
    end

    % Appels entre CA1 et CA3
    % Trajet : CA1 <--> CTS1 <--> CA3
    if appels(3)
        if ~CA1_CTS1
            echec_appel =+ 1;
            crash_comm = [3 1 5];
        elseif ~CA3_CTS1
            echec_appel =+ 1;
            crash_comm = [3 1 5];
        else
           reussi_appel =+ 1;
           CA1_CTS1 = CA1_CTS1 - 1; % CA1 <-> CTS1
           CA3_CTS1 = CA3_CTS1 - 1; % CTS1 <-> CA3
           z = find(memoire(:,3)==0);
           memoire(z(1),3) = randi(d);
        end
    end

    % Cherchons le nombre d'appels CA1 <-> CA2 qui vont terminer
    nb1 = sum(memoire(:,1) == 1);
    CA1_CA2 = CA1_CA2 + nb1; % ajout des appels libérés dans notre capacité

    % Cherchons le nombre d'appels CA2 <-> CA3 qui vont terminer
    nb2 = sum(memoire(:,2) == 1);
    CA2_CA3 = CA2_CA3 + nb2;

    % Cherchons le nombre d'appels CA1 <-> CA3 qui vont terminer
    nb3 = sum(memoire(:,3) == 1);
    CA1_CTS1 = CA1_CTS1 + nb3;
    CA3_CTS1 = CA3_CTS1 + nb3;

    % Le temps passe
    t = t + 1;
    [~, id] = find(memoire(:)>=1);
    memoire(id) = memoire(id) - 1;

end


% Taux de réussite établissement d'un appel
taux_reussite = 100 * reussi_appel / (echec_appel + reussi_appel);
disp("Taux d'appels réussis = " + taux_reussite + "%");

% Mise à jour de la matrice
    M = [0 CTS1_CTS2 CA1_CTS1 CA2_CTS1 CA3_CTS1;
    CTS1_CTS2 0 CA1_CTS2 CA2_CTS2 CA3_CTS2;
    CA1_CTS1 CA1_CTS2 0 CA1_CA2 0;
    CA2_CTS1 CA2_CTS2 CA1_CA2 0 CA2_CA3;
    CA3_CTS1 CA3_CTS2 0 CA2_CA3 0];


% Graphe du réseaux saturé
noms = {'CTS1', 'CTS2', 'CA1', 'CA2', 'CA3'};
G = graph(M, noms, 'upper','omitselfloops');
x = [-0.5 0.5 -1 0 1];
y = [1 1 -0.5 -1 -0.5];
p = plot(G,'XData',x,'YData',y,'EdgeLabel',G.Edges.Weight);


% Affichage communication bloquante
highlight(p,crash_comm,'EdgeColor', 'g');

