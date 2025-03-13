Docker Swarm Learning Lab

Notes:

start docker swarm
`docker swarm init`

exit docker swarm
for manager
`docker swarm leave --force`
for worker
`docker swarm leave`

Remove docker stack
`docker stack rm mystack`

Remove all secret
`docker secret ls -q | xargs docker secret rm`