# Docker and GitLab EE Installation Ansible Project

This Ansible project automates the installation of Docker and GitLab EE on Ubuntu systems. It follows best practices for Ansible project structure and provides reusable roles for Docker and GitLab installation.

## Project Structure

```
ansible/
├── install_docker.yaml        # Docker installation playbook
├── install_gitlab.yaml        # GitLab EE installation playbook
├── README.md                  # This documentation file
├── inventory/
│   ├── hosts                  # Inventory file with target hosts
│   └── group_vars/
│       └── all.yml            # Variables applied to all hosts
└── roles/
    ├── docker/                # Docker installation role
    │   ├── tasks/
    │   │   └── main.yml       # Tasks for Docker installation
    │   ├── handlers/
    │   │   └── main.yml       # Handlers for Docker service
    │   └── defaults/
    │       └── main.yml       # Default variables for the role
    └── gitlab/                # GitLab installation role
        ├── tasks/
        │   └── main.yml       # Tasks for GitLab installation
        ├── templates/
        │   └── docker-compose.yml.j2  # Docker Compose template for GitLab
        └── defaults/
            └── main.yml       # Default variables for GitLab
```

## Features

### Docker Installation
- Checks if Docker is already installed before attempting installation
- Follows the official Docker installation procedure for Ubuntu
- Sets up the Docker repository with proper GPG key
- Installs Docker packages (docker-ce, docker-ce-cli, containerd.io, etc.)
- Verifies the installation by checking Docker version
- Uses proper Ansible role structure for reusability

### GitLab EE Installation
- Installs GitLab EE using Docker Compose
- Configures GitLab with customizable settings
- Sets up persistent storage for GitLab data
- Configures networking, SMTP, and backup settings
- Waits for GitLab to become available
- Provides instructions for accessing GitLab and retrieving the initial root password

## Prerequisites

- Ansible 2.9 or higher
- Target Ubuntu servers with sudo access
- SSH access to target servers
- Sufficient disk space for GitLab (at least 10GB recommended)

## Usage

### Docker Installation

Run the Docker installation playbook:

```bash
ansible-playbook -i inventory/hosts install_docker.yaml
```

### GitLab EE Installation

Run the GitLab installation playbook:

```bash
ansible-playbook -i inventory/hosts install_gitlab.yaml
```

### Run Against Specific Hosts

To run against specific hosts or groups:

```bash
ansible-playbook -i inventory/hosts install_docker.yaml --limit webservers
ansible-playbook -i inventory/hosts install_gitlab.yaml --limit gitlab-ee
```

### Run Locally

To run on the local machine:

```bash
ansible-playbook -i inventory/hosts install_docker.yaml --limit localhost
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

[gitlab-ee]
gitlab.example.com
```

### Docker Role Variables

You can customize the Docker installation by modifying variables in `roles/docker/defaults/main.yml`:

- `docker_version`: Specify a Docker version (empty for latest)
- `docker_start_on_boot`: Whether to start Docker on boot (default: true)
- `docker_users`: List of users to add to the Docker group

### GitLab Role Variables

You can customize the GitLab installation by modifying variables in `roles/gitlab/defaults/main.yml`:

- `gitlab_version`: GitLab version (latest by default)
- `gitlab_hostname`: GitLab instance hostname
- `gitlab_home`: Directory where GitLab data will be stored
- `gitlab_external_url`: External URL for GitLab access
- `gitlab_http_port`, `gitlab_https_port`, `gitlab_ssh_port`: Port mappings
- SMTP and backup settings

## After GitLab Installation

Once GitLab installation completes:

1. Wait a few minutes for GitLab to complete its initial setup
2. Access GitLab at the URL shown in the output (http://your-server-ip)
3. Retrieve the initial root password using:
   ```bash
   docker exec -it $(docker ps -q --filter "name=gitlab_gitlab") grep 'Password:' /etc/gitlab/initial_root_password
   ```
4. Log in with username `root` and the retrieved password
5. Change the root password immediately (the initial password is only valid for 24 hours)

## Troubleshooting

### Docker Installation Fails

- Check internet connectivity on the target server
- Verify that the target system is a supported Ubuntu version
- Ensure the user has sufficient privileges

### GitLab Installation Issues

- Ensure Docker and Docker Compose are properly installed
- Check if ports 80, 443, and 22 are available
- Verify that the server has sufficient resources (CPU, RAM, disk space)
- Check GitLab logs: `docker compose logs -f`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Your Name