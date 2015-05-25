<!DOCTYPE html>
<html ng-app="mainApp">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>A Fancy Page</title>
    <link rel="icon" href="http://sstatic.net/so/favicon.ico" />
    <link href="/css/bootstrap.min.css" rel="stylesheet" />
    <script src="/js/jquery.min.js"></script>
    <script src="/js/bootstrap.min.js"></script>
    <script src="/js/angular.js"></script>
  </head>
  <body ng-controller="MainCtrl">
    <div class="container">
      <div class="jumbotron" style="margin-top:50px;">
        <h1><%= @message %></h1>
        <p>{{ notification }}</p>
      </div>
    </div>
    <script>
      app = angular.module("mainApp", []);

      app.controller("MainCtrl", function($scope) {
        $scope.notification = "Angular is Working!";
      });
    </script>
  </body>
</html>
