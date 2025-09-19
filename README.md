# Docker Installation Ansible Project

This Ansible project automates the installation of Docker on Ubuntu systems. It follows best practices for Ansible project structure and provides a reusable Docker installation role.

## Project Structure

```
ansible/
├── install_docker.yaml        # Main playbook
├── README.md                  # This documentation file
├── inventory/
│   ├── hosts                  # Inventory file with target hosts
│   └── group_vars/
│       └── all.yml            # Variables applied to all hosts
└── roles/
    └── docker/                # Docker installation role
        ├── tasks/
        │   └── main.yml       # Tasks for Docker installation
        ├── handlers/
        │   └── main.yml       # Handlers for Docker service
        └── defaults/
            └── main.yml       # Default variables for the role
```

## Features

- Checks if Docker is already installed before attempting installation
- Follows the official Docker installation procedure for Ubuntu
- Sets up the Docker repository with proper GPG key
- Installs Docker packages (docker-ce, docker-ce-cli, containerd.io, etc.)
- Verifies the installation by checking Docker version
- Uses proper Ansible role structure for reusability

## Prerequisites

- Ansible 2.9 or higher
- Target Ubuntu servers with sudo access
- SSH access to target servers

## Usage

### Basic Usage

Run the playbook against all hosts in your inventory:

```bash
ansible-playbook -i inventory/hosts install_docker.yaml
```

### Run Against Specific Hosts

To run against specific hosts or groups:

```bash
ansible-playbook -i inventory/hosts install_docker.yaml --limit webservers
```

### Run Locally

To run on the local machine:

```bash
ansible-playbook -i inventory/hosts install_docker.yaml --limit localhost
```

Or with connection local:

```bash
ansible-playbook -c local -i localhost, install_docker.yaml
```

## Configuration

### Inventory Configuration

Edit the `inventory/hosts` file to add your target servers:

```ini
[webservers]
web1.example.com
web2.example.com

[dbservers]
db1.example.com
```

### Role Variables

You can customize the Docker installation by modifying variables in `roles/docker/defaults/main.yml`:

- `docker_version`: Specify a Docker version (empty for latest)
- `docker_start_on_boot`: Whether to start Docker on boot (default: true)
- `docker_users`: List of users to add to the Docker group

## Extending the Project

### Adding Users to Docker Group

To add users to the Docker group, modify the Docker role or add a task to your playbook.

### Installing Docker Compose

You can extend the role to install Docker Compose by adding additional tasks.

## Troubleshooting

### Docker Installation Fails

- Check internet connectivity on the target server
- Verify that the target system is a supported Ubuntu version
- Ensure the user has sufficient privileges

### Docker Command Not Found

- Check if the installation completed successfully
- Verify that the PATH includes the Docker binary location

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Your Name