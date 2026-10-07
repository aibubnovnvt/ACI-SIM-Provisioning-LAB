# ACI-SIM Provisioning LAB

ACI-SIM provisioning lab scripts. This project provisions an ACI-SIM fabric from scratch via Ansible and makes it
available for integration with the other components of the network.

---

## Step-by-Step: Running the Automation

1. Install git on the Ubuntu machine:
   ```bash
   sudo apt-get update
   sudo apt-get install -y git
   ```
2. Get to the Automation server.
3. Pull down the project from git:
   ```bash
   git clone https://github.com/aibubnovnvt/ACI-SIM-Provisioning-LAB.git .
   ```
4. `cd` into the project folder.
5. Execute environment setup:
   ```bash
   ./setup_env.sh
   ```
6. Activate the venv environment created by the script:
   ```bash
   source venv/bin/activate
   ```
7. Go to the `POD1_config` folder. Find the aggregated playbook named `ACI_Simulator_Site.yml`.
   ```bash
   cd POD1_config
   ```
8. Run the playbook and keep track of execution:
   ```bash
   env https_proxy= ansible-playbook -i POD1 ACI_Simulator_Site.yml
   ```
9. The first series of tasks starts the ACI-SIM VM, then pauses execution for ~400 seconds to let the ACI VM load. The VM is loaded and ready for the next set of tasks only when its CLI state reaches the ACI topology selection prompt (small topology is selected automatically). This pause is crucial for the setup wizard on the ACI-SIM console to proceed correctly.
10. Once ACI-SIM console provisioning is done, the play pauses for another 300 seconds to let the VM fully boot and become reachable over HTTPS for the remaining API-driven stages.
11. Review the play recap at the end of the run to confirm all stages completed successfully.
12. To run the SPRT tool, Docker is required. Move from the `POD1_config` folder to the `SPRT` folder at the project root and run the install script:
    ```bash
    cd ../SPRT
    ./install_docker.sh
    ```
    Once the script finishes, confirm Docker installed correctly:
    ```bash
    docker --version
    ```
13. To start the SPRT containers:
    ```bash
    docker compose up -d
    ```
14. Check that SPRT is running on the local server:
    ```bash
    curl -I http://localhost
    ```

---

## Repository layout
```
.
├── .gitignore
├── .python-version
├── LICENSE
├── README.md
├── requirements.txt       # pip packages (Ansible + Python deps)
├── requirements.yml       # Ansible Galaxy collections
├── setup_env.sh           # bootstraps venv + installs everything above
├── SPRT/
│   ├── install_docker.sh                       # installs Docker CE (prerequisite for the SPRT containers)
│   └── docker-compose.yml                      # brings up the SPRT tool + its dependent services
└── POD1_config/
    ├── POD1                                       # inventory (hosts/vars for your lab)
    ├── ACI_Simulator_Site.yml                      # <- run this: orchestrates everything below in order
    ├── ACI_Simulator_Full.yml                      # VM boot + fabric registration
    ├── ACI_Simulator_Tenants.yml                   # tenants/VRFs/BDs/EPGs/contracts
    ├── ACI_Simulator_Networking.yml                # L3Outs / OSPF
    ├── ACI_Simulator_ESG.yml                       # Endpoint Security Groups
    ├── ACI_Simulator_HTTP_RPS_throttle.yml         # HTTP/HTTPS request throttling
    ├── ACI_Simulator_AccessPolicy_Bare_Metal.yml   # access policies for bare-metal ports
    ├── ACI_Simulator_DNS.yml                       # DNS provider/domain
    ├── EP_provisioning_bulk_5.sh                   # runs static_ep/*.py in order, fails fast
    ├── static_ep/                                  # bulk static-endpoint python scripts
    ├── ospf_area.j2                                # Jinja2 templates used by Networking.yml
    └── ospf_if_profile.j2
```
