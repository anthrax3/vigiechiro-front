'use strict'


###*
 # @ngdoc overview
 # @name vigiechiroApp
 # @description
 # # vigiechiroApp
 #
 # Main module of the application.
###
angular
  .module('vigiechiroApp', [
    'ngAnimate',
    'ngCookies',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'ngResource',
    'http-auth-interceptor',
    'flow',
    'appSettings',
    'xin_login',
    'xin_user_status',
    'xin_content',
    'xin_session',
    'xin_backend',
    'xin_listResource',
    'listUtilisateurs',
    'showUtilisateur',
    'listTaxons',
    'showTaxon'
  ])
  .run (Backend, SETTINGS) ->
    Backend.setBaseUrl(SETTINGS.API_DOMAIN)
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'scripts/views/welcome/welcome.html'
      .when '/utilisateurs',
        templateUrl: 'scripts/views/list_utilisateurs.html'
        controller: 'ListResourceCtrl'
        resolve: {resourceBackend: (Backend) -> Backend.all('utilisateurs')}
      .when '/utilisateurs/:userId',
        templateUrl: 'scripts/views/show_utilisateur/show_utilisateur.html'
        controller: 'ShowUtilisateurCtrl'
      .when '/profil',
        templateUrl: 'scripts/views/show_utilisateur/show_utilisateur.html'
        controller: 'ShowUtilisateurCtrl'
        resolve: {$routeParams: (session) -> return {'userId': session.get_user_id()}}
      .when '/taxons',
        templateUrl: 'scripts/views/list_taxons/list_taxons.html'
        controller: 'ListTaxonsCtrl'
      .when '/taxons/nouveau-taxon',
        templateUrl: 'scripts/views/show_taxon/show_taxon.html'
        controller: 'ShowTaxonCtrl'
        resolve: {action: -> 'createNew'}
      .when '/taxons/:taxonId',
        templateUrl: 'scripts/views/show_taxon/show_taxon.html'
        controller: 'ShowTaxonCtrl'
        resolve: {action: -> 'edit'}
      .when '/403',
        templateUrl: '403.html'
      .when '/404',
        templateUrl: '404.html'
      .otherwise
        redirectTo: '/404'
