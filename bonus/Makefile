BBLU		=	\033[1;34m
BGREEN		=	\033[1;32m
BRED		=	\033[1;31m
BLU			=	\033[0;34m
GRN			=	\033[0;32m
RED			=	\033[0;31m
RST			=	\033[0m

NAME		=	bonus

USERNAME := $(shell whoami)

# Detect the OS
UNAME_S := $(shell uname -s)

all: print_header up clean

print_header:
	@echo "$(BBLU)===================================================="
	@echo "$(BBLU)"
	@echo "$(BBLU)\033[17G██╗░█████╗░████████╗"
	@echo "$(BBLU)\033[17G██║██╔══██╗╚══██╔══╝"
	@echo "$(BBLU)\033[17G██║██║░░██║░░░██║░░░"
	@echo "$(BBLU)\033[17G██║██║░░██║░░░██║░░░"
	@echo "$(BBLU)\033[17G██║╚█████╔╝░░░██║░░░"
	@echo "$(BBLU)\033[17G╚═╝░╚════╝░░░░╚═╝░░░"
	@echo "$(BBLU)"
	@echo "$(BBLU)=====================> bonus <======================"
	@echo "$(RST)"

up:
ifeq ($(UNAME_S),Linux)
	@echo "${YELLOW}Running scripts on Linux ...${END}"
	@sudo ./scripts/prerequisities.sh && ./scripts/k3d.sh && ./scripts/argocd.sh && ./scripts/gitlab.sh && ./scripts/dev.sh
else ifeq ($(UNAME_S),Darwin)
	@echo "${YELLOW}Running scripts on macOS ...${END}"
	@./scripts/k3d.sh && ./scripts/argocd.sh && ./scripts/gitlab.sh && ./scripts/dev.sh
endif

clean:
	${RM} ./confs/kubectl
	${RM} ./confs/kubectl.sha256 
	${RM} ./.gitlab_password 
	echo "$(RED)[CLEAN]  :$(RST) Cleaning project...$(BGREEN)\033[47G[✔]$(RST)"

fclean:
	${RM} ./confs/kubectl
	${RM} ./confs/kubectl.sha256
	${RM} ./.gitlab_password
	@sudo k3d cluster delete $(USERNAME)
	@rm -rf /tmp/jsrassik
	echo "$(RED)[CLEAN]  :$(RST) Cleaning project and delete cluster...$(BGREEN)\033[47G[✔]$(RST)"

.SILENT:

.PHONY: all print_header up clean fclean