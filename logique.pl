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
occur_check(V,T) :- var(V),contains_var(V,T).

% Rename {x ?= t}∪P′;S -> P′[x/t];S[x/t]∪{x=t} si t est une variable
regle(_?= T,rename) :- var(T),!.

% Simplify {x ?= t}∪P′;S -> P′[x/t];S[x/t]∪{x=t} si t est une constante
regle(X ?= T,simplify) :- var(X), atomic(T),!.
% Revoir plus tard pour atomic(T)

% Expand {x ?= t}∪P′;S -> P′[x/t];S[x/t]∪{x=t} si t est composé et x n’apparaît pas dans t
regle(X ?= T,expand) :- compound(T),var(X),not(occur_check(X,T)),!.

% Check {x?=t}∪P′;S->⊥ si x!=t et x apparaît dans t
regle(X?=T,check) :- X \== T, occur_check(X,T),!.

% Orient {?=x}∪P′;S->{x=?t}∪P′;S si t n’est pas une variable
regle(T?=_,orient) :- nonvar(T),!.

% Decompose {f(s,···,s)?=f(t,···,t)}∪P′;S->{s?=t,···,s?=t}∪P′;S
regle((X ?= T), decompose) :- compound(X), compound(T), functor(X, N1, NB1), functor(T, N2, NB2), N1 == N2, NB1 == NB2,!.

% Clash {f(s,···,s)?=g(t,···,t)}∪P′;S->⊥ si f!=g ou m!=n
regle((X ?= T), clash) :- compound(X), compound(T), functor(X, N1, NB1), functor(T, N2, NB2), (not(N1 == N2) ; not(NB1 == NB2)),!.


% reduit(R,E,P,Q) : transforme le système d’équations P en le système d’équations Q par application
% de la règle de transformation R à l’équation E.

% rename
% reduit(rename,X?=Z,[f(X,Y)?=f(X,X),g(X,E)],Q).
% Est-ce qu'il faut avoir E dans P ?????????????? 
% Il le faut surement car la regle doit être supprime
% Si E est dedans on supprime pas E dans les 1eres regles
reduit(rename, (X ?= T), P, Q) :- regle((X?=T),rename),echo(rename : X = T),nl, X=T, Q=P, !.

% simplify
% reduit(simplify,Y?=a,[f(X,Y)?=f(X,X)|Y?=a],Q).
% Avec cette regle on remplace Y par a
reduit(simplify, (X ?= T), P, Q) :- regle((X?=T),simplify),echo(simplify : X = T),nl, X=T, Q=P, !.

% expand
reduit(expand, (X ?= T), P, Q) :- regle((X?=T),expand),echo(expand : X = T),nl, X=T, Q=P, !.

% check
%reduit(check,E,P,Q) :- !.

% orient
%reduit(orient,E,P,Q) :- !.

% decompose
%reduit(decompose,E,P,Q) :- !.

% clash
%reduit(clash,E,P,Q) :- !.


