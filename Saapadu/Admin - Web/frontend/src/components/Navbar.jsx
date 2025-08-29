import React, {useEffect, useState} from "react";
import {Navbar, Nav, Container} from "react-bootstrap";
import {Link} from "react-router-dom";
import "./Navbar.css";


function NavbarComponent() {

    const [college, setCollege] = useState(null);
    useEffect(() => {
        try {
            const savedCollege = JSON.parse(localStorage.getItem("college"));
            setCollege(savedCollege);
        } catch {
            setCollege(null);
        }
    }, []);
    return (
        <Navbar collapseOnSelect bg="dark" variant="dark" expand="lg" fixed="top" className="custom-navbar" sticky="top">
            <Container fluid>
                <Navbar.Brand as={Link} to="/home">
                    <span className="college-name text-truncate">{college?.name ?? "Saapadu"}</span>
                </Navbar.Brand>
                <Navbar.Toggle aria-controls="basic-navbar-nav" className="ms-auto"/>
                <Navbar.Collapse id="basic-navbar-nav">
                    <Nav className="ms-auto">
                        <Nav.Link as={Link} to="/home">Home</Nav.Link>
                        <Nav.Link as={Link} to="/home">Shops</Nav.Link>
                        <Nav.Link as={Link} to="/home">Orders</Nav.Link>
                        <Nav.Link as={Link} to="/home">Payment</Nav.Link>
                        <Nav.Link as={Link} to="/home">Feedback</Nav.Link>
                        <Nav.Link as={Link} to="/home">Analytics</Nav.Link>
                        <Nav.Link as={Link} to="/home">Setting</Nav.Link>
                        <Nav.Link as={Link} to="/signIn" onClick={() => localStorage.clear()}>Logout</Nav.Link>
                    </Nav>
                </Navbar.Collapse>
            </Container>
        </Navbar>
    );
}

export default NavbarComponent;
