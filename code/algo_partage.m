clear all;
close all;

%% Paramètres de la simulation
n = 10; % Nombre de téléphones par station 
T = 10*60; % Durée totale de la simulation (en secondes)
d = 20*60; % Durée maximale d'un appel (en secondes)

%% Capacités initiales des liens
CA1_CA2 = 10;
CA2_CA3 = 10;
CA1_CTS1 = 100;
CA1_CTS2 = 100;
CA2_CTS1 = 100;
CA2_CTS2 = 100;
CA3_CTS1 = 100;
CA3_CTS2 = 100;
CTS1_CTS2 = 1000;

%% Capacités actuelles des liens
capacitesInitiales = [CA1_CA2, CA2_CA3, CA1_CTS1, CA1_CTS2, CA2_CTS1, CA2_CTS2, CA3_CTS1, CA3_CTS2, CTS1_CTS2];
capacitesActuelles = capacitesInitiales;

%% Initialisation des compteurs
echec_appel = 0; % Nombre d'communication échoués
reussi_appel = 0; % Nombre d'communication réussis
proba_appel = 0.5; % Probabilité d'un appel
memoire = zeros(T,9); % communication en cours (durée restante pour chaque lien)

%% Boucle de simulation
t = 1; % Temps initial
while t < T
    % Génération aléatoire des communication
    communication = rand(1,3) < proba_appel;
    
    % Gestion des communication
    for i = 1:3
        if communication(i)
            
            % Filtrer les liens avec au moins un emplacement disponible
            liensDisponibles = find(capacitesActuelles > 0);

            if isempty(liensDisponibles)
                echec_appel = echec_appel + 1;
            end
            if ~isempty(liensDisponibles)
                % Calculer le pourcentage de capacité utilisée pour chaque lien
                pourcentageCapaciteUtilisee = (1 - (capacitesActuelles./capacitesInitiales))*100;
                % Trouver le lien avec le pourcentage de capacité utilisée le plus faible
                [~, idxMin] = min(pourcentageCapaciteUtilisee(liensDisponibles));
                idxLien = liensDisponibles(idxMin);

                % Réduire la capacité disponible du lien
                capacitesActuelles(idxLien) = capacitesActuelles(idxLien) - 1;

                % Mise à jour de la matrice memoire pour la durée de l'appel
                memoire(t, idxLien) = d;

                reussi_appel = reussi_appel + 1;
            end
        end
    end
     % Libération des ressources des communication terminés
    if t>0
        if memoire(t, i) > 0 
            % Décrémenter la durée restante de l'appel
            memoire(t, i) = memoire(t, i) - 1;

            % Restaurer la capacité si l'appel est terminé
            if memoire(t, i) == 0
                capacitesActuelles(i) = capacitesActuelles(i) + 1;
            end
        end
    end

    % Mise à jour du temps
    t = t + 1;
end

%% Calcul du taux de réussite des communication
taux_reussite = 100 * reussi_appel / (echec_appel + reussi_appel);
disp(['Taux d''communication réussis = ', num2str(taux_reussite), '%']);

%% Affichage du graphe du réseau
nomsNoeuds = {'CA1', 'CA2', 'CA3', 'CTS1', 'CTS2'};
capacitesInitiales = [CA1_CA2, CA2_CA3, CA1_CTS1, CA1_CTS2, CA2_CTS1, CA2_CTS2, CA3_CTS1, CA3_CTS2, CTS1_CTS2];

% Créer une matrice d'adjacence à partir des capacités initiales
M = [0 CTS1_CTS2 CA1_CTS1 CA2_CTS1 CA3_CTS1;
     CTS1_CTS2 0 CA1_CTS2 CA2_CTS2 CA3_CTS2;
     CA1_CTS1 CA1_CTS2 0 0 0;
     CA2_CTS1 CA2_CTS2 CA1_CA2 0 CA2_CA3;
     CA3_CTS1 CA3_CTS2 0 CA2_CA3 0];




title('Graphe du Réseau de Télécommunications');
xlabel('Position X');
ylabel('Position Y');

% Graphe du réseaux saturé
noms = {'CTS1', 'CTS2', 'CA1', 'CA2', 'CA3'};
G = graph(M, noms, 'upper','omitselfloops');
x = [-0.5 0.5 -1 0 1];
y = [1 1 -0.5 -1 -0.5];
p = plot(G,'XData',x,'YData',y,'EdgeLabel',G.Edges.Weight);


%% Calcul des capacités restantes
M_finale = [0, 0, capacitesActuelles(1), capacitesActuelles(3), capacitesActuelles(4);
            0, 0, capacitesActuelles(2), capacitesActuelles(5), capacitesActuelles(6);
            capacitesActuelles(1), capacitesActuelles(2), 0, 0, 0;
            capacitesActuelles(3), capacitesActuelles(5), 0, 0, capacitesActuelles(9);
            capacitesActuelles(4), capacitesActuelles(6), 0, capacitesActuelles(9), 0];

%% Création et affichage du graphe avec les capacités restantes
G_finale = graph(M_finale, noms, 'upper', 'omitselfloops');
figure;
p_finale = plot(G_finale, 'XData', x, 'YData', y, 'EdgeLabel', G_finale.Edges.Weight);

title('Graphe du Réseau de Télécommunications avec Capacités Restantes');
xlabel('Position X');
ylabel('Position Y');

