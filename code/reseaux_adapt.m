close all
clear all

%% Projet Réseaux de télécommunications

n = 10; % Nombre de téléphones par station 
T = 100; % Dernier établissement de communication possible (s)
d = 100;%5*60; % Durée maximale d'un appel (s) ; répartition uniforme

% Notre graphe
% Capacité des liens CA_CA
CA1_CA2 = 10;
CA2_CA3 = 10;

% Capacité des liens CA_CTS
CA1_CTS1 = 100;

CA1_CTS2 = 100;

CA2_CTS1 = 100;

CA2_CTS2 = 100;

CA3_CTS1 = 100;

CA3_CTS2 = 100;

% Capacité du lien CTS_CTS
CTS1_CTS2 = 1000;

% Matrice de liens
M = [0 CTS1_CTS2 CA1_CTS1 CA2_CTS1 CA3_CTS1;
    CTS1_CTS2 0 CA1_CTS2 CA2_CTS2 CA3_CTS2;
    CA1_CTS1 CA1_CTS2 0 CA1_CA2 0;
    CA2_CTS1 CA2_CTS2 CA1_CA2 0 CA2_CA3;
    CA3_CTS1 CA3_CTS2 0 CA2_CA3 0];





% Graphe du réseaux


G = graph(M, 'upper', 'omitselfloops');

% Initialisation
p_appel = 0.5; % Probabilité d'un appel
t = 1; % Indice de temps (s)

appels_echec = 0; % Nombre d'appels échoué

appels_reussi = 0; % Nombre d'appels réussi




memoire = repmat(struct('temps', 0, 'nodes', []), 1000, 1 );



while ( t < T )


    appel = rand(1) < p_appel; % Déclenche un appel avec une proba de p_appel
    appel = appel * randi([1 3]);

    % appels = 1 : communication entre 2 et 1


    % appels = 2 : communication entre 2 et 3


    % appels = 3 : communication entre 1 et 3

    % Algorithme Adaptatif
    if (appel ~=0)



        % On cherche le chemin le plus court
        x = mod(appel+1,2)+3; % 1->3, 2->4, 3->3 

        y = mod(3+5*(appel-1),2)+mod(3+5*(appel-1),3)+3; % 1->4, 2->5, 3->4 


        [~, ~, lien] = shortestpath(G,x,y,'Method','unweighted');

        % On vérifie que la communication est possible
        if (~isempty(lien))

            


            % Communication acceptée
            appels_reussi = appels_reussi + 1;
            G.Edges.Weight(lien, :) = G.Edges.Weight(lien, :) - 1;
            z = find([memoire(:).temps]==0);
            memoire(z(1)).temps = randi(d);
            memoire(z(1)).nodes = G.Edges.EndNodes(lien,:);

            % Communication bloquante
            if ( sum ( G.Edges.Weight(lien, :)==0) ~=0 )
                % On suprimme les liens bloquants
                nodes = G.Edges.EndNodes(G.Edges.Weight==0,:);
                edge = findedge(G,nodes(:,1), nodes(:,2));
                G = rmedge(G, edge );
            end 

        else
            % Communication refusée
            appels_echec = appels_echec + 1;
        end

        
        % Cherchons les appels qui vont terminer
        index = find([memoire(:).temps]==1);
        if (~isempty(index))
            for i = index

                % On récupère les nodes

                nodes = memoire(i).nodes;

                % On vérifie que le lien existe (non bloqué)
                lien_bloque = (findedge(G, nodes(:,1), nodes(:,2)) == 0); % 0 -> lien existe
                                                                          % 1 -> lien n'existe pas                                                            

                % On les ajoute
                nodes_new = nodes .* lien_bloque;

                nodes_new = nodes_new(nodes_new>0);
                l = length(nodes_new);
                if (l == 2)
                    nodes_new;

                    G = addedge(G, nodes_new(1), nodes_new(2), 1);
                    G.Edges.Weight
                elseif (l > 2)
                    nodes_new;
                    for i = 1 : l/2

                        G = addedge(G, nodes_new(i), nodes_new(i+l/2), 1);
                    end
                end

                % On récupère les liens 
                lien = findedge(G, nodes(:,1), nodes(:,2));

                % Et on augmente leur capacité
                G.Edges.Weight(lien) = G.Edges.Weight(lien) + 1;
                
            end
        end
    end

    % Le temps passe
        t = t + 1;
        [~, index] = find([memoire(:).temps]>=1);
        if (~isempty(index))
            for i = index
                memoire(i).temps = memoire(i).temps - 1;
            end
        end

end

% Graphe du réseaux saturé

x = [-0.5 0.5 -1 0 1];
y = [1 1 -0.5 -1 -0.5];


figure;

plot(G,'XData',x,'YData',y,'EdgeLabel',G.Edges.Weight);

% Taux de réussite 

taux_reussite = 100 * appels_reussi / (appels_echec + appels_reussi)










