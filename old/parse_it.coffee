fs = require 'fs'
parser = require './graphql'

gql = fs.readFileSync './gql.txt', 'utf8'

console.log parser.parse gql




