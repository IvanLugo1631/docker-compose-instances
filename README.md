# Docker - Odoo
Docker recipe to generate deploy Odoo instances.

## Deploy
Consider the following steps for a correct deploy.

- On odoo directory, we will clone the following repositories:
    - [odoo](https://github.com/odoo/odoo)
    - [enterprise](https://github.com/odoo/enterprise)
    - [design-themes](https://github.com/odoo/design-themes)
- On odoo/custom directory, we will clone the custom repositories needed
- Add Odoo requirements:
    - On file requirements.txt we will copy the content of odoo/odoo/requirements.txt file
    - Change psycopg2 intances for psycopg2-binary
- Add custom requirements:
    - On file requirements_2.txt we will copy all the content of requirements files on custom repositories
- Change Odoo version, replacing all 'odoo1X', 'OdooDB1X' instances on project, for the apropiate odoo versión. Ex. 'odoo15' 

## Execution
Consider the following steps for a correct execution. All the commands must be executed on the root folder of the project. 
### Build project
First step is build the project. After the deploy configurations, we will execute the command:
```docker-compose up --build```
This command will build the images for odoo and postgresql, if any error does not ocurr, odoo service will be up. If we faced an error through the deploy and we modifiy one of docker files, we need to execute the same command in order to the images takes the changes. The time to complete this operation depends on intermediate containers build by docker, a change on a requirements.txt does not take as long as a change on dockerfile. 

### Operation commands
The following commands are available for multiple operations:
- **Up detattached mode**: `docker-compose up -d`
    - This command ups all containers without building the images.
- **Down**: `docker-compose down`
    - This command delete all cointainers but preserve volume data. To delete all data related (including volumes) execute: `docker-compose down -v`
- **Start**: `docker-compose start`
    - This commmand starts all the containers related to a project, after they were stopped. If they were downed, must execute the `up` command.
- **Stop**: `docker-compose stop`
    - This command stops all the containers related to a project, without deleting containers. 
- **Restart**: `docker-compose restart`
    - This command restarts all the containers related to a project.

## Notes
Some observations to consider:
- Command `docker-compose` must be execute with sudo permissions.
