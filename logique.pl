% Mulhauser remy
% Wolkowicz michel


% CODE D'AFFICHAGE FOURNI 

:- op(20,xfy,?=).

% Prédicats d'affichage fournis

% set_echo: ce prédicat active l'affichage par le prédicat echo
set_echo :- assert(echo_on).

% clr_echo: ce prédicat inhibe l'affichage par le prédicat echo
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionné, echo(T) affiche le terme T
%          sinon, echo(T) réussit simplement en ne faisant rien.

echo_on.
echo(T) :- echo_on, !, write(T).
echo(_).



% PREDICATS

% regle(E,R) : détermine la règle de transformation R qui s’applique à l’équation E, par exemple, le
% but ?- regle(f(a) ?= f(b),decompose) réussit.
% occur_check(V,T) : teste si la variable V apparaît dans le terme T.
% reduit(R,E,P,Q) : transforme le système d’équations P en le système d’équations Q par application
% de la règle de transformation R à l’équation E.

% occur_check(V,T) : teste si la variable V apparaît dans le terme T.
% première version de occur_check pas bonne car on teste que pour des variable
%occur_check(V,T) :- var(V),contains_var(V,T).
occur_check(V,T) :- V==T -> !;compound(T), functor(T,_,A),occur_check_compose(V,T,A), !.
occur_check_compose(V,T,A) :- A==1 ->arg(1,T,X),occur_check(V,X);arg(A,T,X),occur_check(V,X);A2 is (A-1),occur_check_compose(V,T,A2), !.

% Rename {x ?= t}∪P′;S -> P′[x/t];S[x/t]∪{x=t} si t est une variable
regle(_?= T,rename) :- var(T),!.

% Simplify {x ?= t}∪P′;S -> P′[x/t];S[x/t]∪{x=t} si t est une constante
regle(X ?= T,simplify) :- var(X), atomic(T),!.
% Revoir plus tard pour atomic(T)

% Expand {x ?= t}∪P′;S -> P′[x/t];S[x/t]∪{x=t} si t est composé et x n’apparaît pas dans t
regle(X ?= T,expand) :- compound(T),var(X),not(occur_check(X,T)),!.

% Check {x?=t}∪P′;S->⊥ si x!=t et x apparaît dans t
regle(X?=T,check) :- X \== T, occur_check(X,T),!.


% Decompose {f(s,···,s)?=f(t,···,t)}∪P′;S->{s?=t,···,s?=t}∪P′;S
regle((X ?= T), decompose) :- compound(X), compound(T), functor(X, N1, NB1), functor(T, N2, NB2), N1 == N2, NB1 == NB2,!.

% Clash {f(s,···,s)?=g(t,···,t)}∪P′;S->⊥ si f!=g ou m!=n
regle((X ?= T), clash) :- compound(X), compound(T), functor(X, N1, NB1), functor(T, N2, NB2), (not(N1 == N2) ; not(NB1 == NB2)),!.

% Orient {?=x}∪P′;S->{x=?t}∪P′;S si t n’est pas une variable
regle(T?=_,orient) :- nonvar(T),!.


% reduit(R,E,P,Q) : transforme le système d’équations P en le système d’équations Q par application
% de la règle de transformation R à l’équation E.

% rename
% reduit(rename,X?=Z,[f(X,Y)?=f(X,X),g(X,E)],Q).
% Est-ce qu'il faut avoir E dans P ?????????????? 
% Il le faut surement car la regle doit être supprime
% Si E est dedans on supprime pas E dans les 1eres regles
reduit(rename, (X ?= T), P, Q) :- echo(rename : X = T),nl, X=T, Q=P, !.

% simplify
% reduit(simplify,Y?=a,[f(X,Y)?=f(X,X)|Y?=a],Q).
% Avec cette regle on remplace Y par a
reduit(simplify, (X ?= T), P, Q) :- echo(simplify : X = T),nl, X=T, Q=P, !.

% expand
reduit(expand, (X ?= T), P, Q) :- echo(expand : X = T),nl, X=T, Q=P, !.

% check
reduit(check,(X ?= T),_,_) :- echo(check : X = T),nl, fail, !.


% decompose
%reduit(decompose,(X ?= T),P,Q) :- regle(X ?= T,decompose),echo(decompose : X = T),!.
% lorsque l'on a f(Z,f(X,Y)) ?= f(a,f(b,c)), decompose sera appelé plusieurs fois donc pas besoin de traiter la profondeur dans cette regle
reduit(decompose, (X ?= T), P, Q) :- echo(decompose : X = T), nl, functor(X,_,A), reduit_decompose((X ?= T),Q,[],P,A), !.
reduit_decompose((X ?= T), Q, Q2,P, A) :- A==0 -> append(Q2,P,Q), !; arg(A,X,X1), arg(A,T,T1), A2 is (A-1), reduit_decompose((X ?= T), Q, [(X1 ?= T1) | Q2 ], P, A2).

% clash
discontiguous reduit(clash,(X ?= T),_,_) :- echo(clash: X = T), nl, fail, !.

% orient
% reduit(orient,a ?= X,[f(Z=e),a ?= X],Q).
discontiguous reduit(orient, (X ?= T), P, [(T ?= X)|P]) :- regle(X ?= T,orient), echo(orient: X ?= T),nl,!.


%unifie(P)
unifie([E|P]) :- echo(system :[E|P]), nl, regle(E,R), reduit(R,E,P,Q), unifie(Q), !.
%Cas d arret
unifie([]) :- !.

%Strategie de base
unifie([E|P],choixpremier) :-  choix_premier([E|P], Q, E, R), unifie(Q,S), !.
choix_premier([E|P], Q, E, R) :- echo(system :[E|P]), nl, reduit(R,E,P,Q), !.


%Strategie pondere
%clash,check > rename,simplify > 
%
%
%
%
%t > decompose > expand
unifie(P,choixpondere) :-  choix_pondere( P, Q, E, R), unifie(Q,S), !.
choix_pondere(P, Q, E, R) :- echo(system :P), nl, coefpondere(r).


%Cas d arret
discontiguous unifie([],S) :- !.





