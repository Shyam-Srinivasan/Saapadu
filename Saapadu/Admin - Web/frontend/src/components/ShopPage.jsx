import React, {useCallback, useEffect, useState} from "react";
import axios from "axios";
import {Alert, Button, Col, Container, Row, Form, Modal, Spinner} from "react-bootstrap";
import {CreateTile} from "./CreateTile";
import {Tile} from "./Tile";

const API_BASE = `http://${window.location.hostname}:8080`;

export const ShopPage = () => {
    const [shops, setShops] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [showCreate, setShowCreate] = useState(false);
    const [submitting, setSubmitting] = useState(false);
    const [form, setForm] = useState({shop_name: "", password: ""});

    const college = (() => {
        try {
            return JSON.parse(localStorage.getItem("college"));
        } catch {
            return null;
        }
    })();

    const loadShops = useCallback(async () => {
        setError("");
        setLoading(true);
        try {
            if (!college?.id) {
                setError("No organization found in session. Please sign in again.");
                return;
            }
            const res = await axios.get(`${API_BASE}/shopList/fetchShop`, {
                params: {collegeId: college.id},
                validateStatus: () => true
            });
            if (res.status === 200 && Array.isArray(res.data)) {
                setShops(res.data);
            } else if (res.status === 204) {
                setShops([]);
            } else if (res.status === 404) {
                setError("Organization not found.");
            } else {
                setError(res.data || "Failed to fetch shops.");
            }
        } catch {
            setError("Error fetching shops. Please try again later.");
        } finally {
            setLoading(false);
        }
    }, [college?.id]);


    useEffect(() => {
        loadShops();
    }, [loadShops]);

    const openCreate = () => {
        setForm({shop_name: "", password: ""});
        setShowCreate(true);
    };

    const closeCreate = () => setShowCreate(false);

    const onFormChange = (e) => {
        const {name, value} = e.target;
        setForm((f) => ({...f, [name]: value}));
    };

    const submitCreate = async (e) => {
        e.preventDefault();
        if (!college?.id) {
            setError("No organization found in session. Please sign in again.")
            return;
        }
        if (!form.shop_name?.trim()) {
            return alert("ShopPage name is required.");
        }
        if (!form.password?.trim()) {
            return alert("Password is required.");
        }

        setSubmitting(true);

        try {
            const payload = {
                shop_name: form.shop_name.trim(),
                password: form.password,
                college_id: college.id
            };

            const res = await axios.post(
                `${API_BASE}/shopList/createShop`,
                payload,
                {
                    validateStatus: () => true
                }
            );
            if (res.status === 201 || res.status === 200) {
                closeCreate();
                await loadShops();
            } else {
                const msg = res.data || "Failed to create shop.";
                alert(msg);
            }
        } catch (err) {
            alert(err.response?.data || "Network error while creating shop");
        } finally {
            setSubmitting(false);
        }
    }

    return (
        <Container fluid className="bg-white min-vh-100">
            <Row className="mb-3">
                <Col className="p-0">
                    <p className="text-center text-white bg-primary m-0 w-100 fs-6 text-uppercase d-flex align-items-center justify-content-center"
                        style={{borderRadius: 0, height: "50px"}}>
                        {college?.name ? `${college.name} - Shops` : "Shops"}
                    </p>
                </Col>
            </Row>

            {loading && (
                <Row>
                    <Col className="d-flex align-items-center">
                        <Spinner animation="border" role="status" className="me-2"/>
                        <span>Loading shops...</span>
                    </Col>
                </Row>
            )}

            {!loading && error && (
                <Row>
                    <Col>
                        <Alert variant="danger">{error}</Alert>
                    </Col>
                </Row>
            )}

            {!loading && !error && shops.length === 0 && (
                <Row>
                    <Col>
                        <Alert variant="info">No shops found for this organization.</Alert>
                    </Col>
                </Row>
            )}

            {!loading && !error && (
                <Row className="g-2 g-lg-1 g-xl-0 justify-content-start">
                    {shops.map((shop) => (
                        <Col key={shop.shop_id ?? shop.shopId} xs="12" sm="6" md="4" lg="3" xl="3">
                            <Tile name={shop.shop_name ?? shop.shopName} id={shop.shop_id ?? shop.shopId}
                                  onUpdate={loadShops} type="shop"
                            />
                        </Col>
                    ))}
                    <Col xs="12" sm="6" md="4" lg="3" xl="3">
                        <CreateTile openCreate={openCreate} type="shop"/>
                    </Col>
                </Row>
            )}

            <Modal show={showCreate} onHide={closeCreate} centered>
                <Form onSubmit={submitCreate}>
                    <Modal.Header closeButton>
                        <Modal.Title>Create Shop</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Form.Group className="mb-3" controlId="shopName">
                            <Form.Label>Shop Name</Form.Label>
                            <Form.Control
                                name="shop_name"
                                type="text"
                                placeholder="Enter shop name"
                                value={form.shop_name}
                                onChange={onFormChange}
                                required
                                maxLength={128}
                            />
                        </Form.Group>
                        <Form.Group className="mb-2" controlId="password">
                            <Form.Label>Password</Form.Label>
                            <Form.Control
                                name="password"
                                type="password"
                                placeholder="Enter password"
                                value={form.password}
                                onChange={onFormChange}
                                required
                                maxLength={16}
                            />
                            <Form.Text muted>Max 16 characters.</Form.Text>
                        </Form.Group>
                    </Modal.Body>
                    <Modal.Footer>
                        <Button variant="secondary" onClick={closeCreate} disabled={submitting}>
                            Cancel
                        </Button>
                        <Button variant="primary" type="submit" disabled={submitting}>
                            {submitting ? "Creating..." : "Create"}
                        </Button>
                    </Modal.Footer>
                </Form>
            </Modal>
        </Container>
    );
};