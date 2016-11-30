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


% Rename {x ?= t}∪P′; S -> P′[x/t]; S[x/t]∪{x=t} si t est une variable
regle(X ?= T,rename) :- var(X), var(T),!.

% Simplify {x ?= t}∪P′; S -> P′[x/t]; S[x/t]∪{x=t} si t est une constante
regle(X ?= T,simplify) :- var(X),!.










